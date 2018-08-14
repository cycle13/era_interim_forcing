%     "step": "3/6/9/12",
%     "time": "00:00:00/12:00:00",
%     'area': "48/-100/7/-59",
%     'format': "netcdf",
%     "grid": "0.125/0.125",

%Parameter/Variables. 

% 2 metre dewpoint temperature  
% 2 metre temperature  
% 10 metre U wind component  
% 10 metre V wind component
% Surface pressure
%  Surface solar radiation downwards  
%  Surface thermal radiation downwards
%  Total precipitation


clear 
clc

for yyyy = 1992:2017
    clearvars -except yyyy
    nn=0;
    for n=1:12
        filename=['/raid0/data/jbzambon/move/ecmwf/era-interim/orig_forcing/ECMWF_',num2str(yyyy),num2str(n,'%02.f'),'.nc']
        time=ncread(filename,'time');
        time=double(time);
        %units     = 'hours since 1900-01-01 00:00:0.0'
        newtime=datenum('1900-01-01 00:00:0.0')+time/24;
        t_time=newtime-datenum('1858-11-17 00:00:00');       %units     = 'days since 1858-11-17 00:00:00'
        nn=length(t_time)+nn;
    end %n

        longitude=ncread(filename,'longitude');
        latitude=ncread(filename,'latitude');
        [lati long]=meshgrid(latitude,longitude);

        lon=long;
        lon=lon-360;
        lat=fliplr(lati);

        [xx, yy]=size(lon);

        Uwind=zeros(xx,yy,nn);
        Vwind=zeros(xx,yy,nn);
        wind_time=zeros(nn,1);

        swrad=zeros(xx,yy,nn);
        lwrad_down=zeros(xx,yy,nn);
        srf_time=zeros(nn,1);
        lrf_time=zeros(nn,1);

        rain=zeros(xx,yy,nn);
        Tair=zeros(xx,yy,nn);
        Pair=zeros(xx,yy,nn);
        rain_time=zeros(nn,1);
        Tair_time=zeros(nn,1);
        Pair_time=zeros(nn,1);

        Qair=zeros(xx,yy,nn);
        Qair_time=zeros(nn,1);

        nn=0;

    for n=1:12
        filename=['/raid0/data/jbzambon/move/ecmwf/era-interim/orig_forcing/ECMWF_',num2str(yyyy),num2str(n,'%02.f'),'.nc']
        time=ncread(filename,'time');
        time=double(time);
        %units     = 'hours since 1900-01-01 00:00:0.0'
        newtime=datenum('1900-01-01 00:00:0.0')+time/24;
        tt=newtime-datenum('1858-11-17 00:00:00');       %units     = 'days since 1858-11-17 00:00:00'

        nn=length(tt)+nn;

        %wind forcing
        u10=ncread(filename,'u10');
        v10=ncread(filename,'v10');
        Uwind(:,:,nn-length(tt)+1:nn)=fliplr(u10);
        Vwind(:,:,nn-length(tt)+1:nn)=fliplr(v10);
        wind_time(nn-length(tt)+1:nn)=tt(:);

        ssrd=ncread(filename,'ssrd');
        strd=ncread(filename,'strd');
        %convert
        ssrd=ssrd./3600./3;
        strd=strd./3600./3;
        swrad(:,:,nn-length(tt)+1:nn)=fliplr(ssrd);
        lwrad_down(:,:,nn-length(tt)+1:nn)=fliplr(strd);
        srf_time(nn-length(tt)+1:nn)=tt(:);
        lrf_time(nn-length(tt)+1:nn)=tt(:);

        tp=ncread(filename,'tp');
        t2m=ncread(filename,'t2m');
        sp=ncread(filename,'sp');
        %convert
        tp=tp.*1000./3600./3;
        t2m=t2m-273.15;  %K to C
        sp=sp./100;  % pa to millibar
        rain(:,:,nn-length(tt)+1:nn)=fliplr(tp);
        Tair(:,:,nn-length(tt)+1:nn)=fliplr(t2m);
        Pair(:,:,nn-length(tt)+1:nn)=fliplr(sp);
        rain_time(nn-length(tt)+1:nn)=tt(:);
        Tair_time(nn-length(tt)+1:nn)=tt(:);
        Pair_time(nn-length(tt)+1:nn)=tt(:);

        tsur=ncread(filename,'t2m');
        tdew=ncread(filename,'d2m');
        tsur=tsur-273.15;
        tdew=tdew-273.15;
        E     = 6.11 .* 10.0 .^ (7.5 .* tdew ./ (237.7 + tdew));
        Es    = 6.11 .* 10.0 .^ (7.5 .* tsur ./ (237.7 + tsur));
        Q= 100.0 .* (E ./ Es);
        Qair(:,:,nn-length(tt)+1:nn)=fliplr(Q);
        Qair_time(nn-length(tt)+1:nn)=tt(:);
    end %n

    %wind
    CLMname = ['useast_wind_era_',num2str(yyyy),'.nc'];

    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'wind_time','Dimensions',{'wind_time',nn});
    ncwriteatt(CLMname,'wind_time','units','days since 1858-11-17 00:00:00');

    nccreate(CLMname,'Uwind','Dimensions',{'lon',xx,'lat',yy,'wind_time',nn});
    nccreate(CLMname,'Vwind','Dimensions',{'lon',xx,'lat',yy,'wind_time',nn});
    ncwriteatt(CLMname,'Uwind','long_name','surface u-wind component');
    ncwriteatt(CLMname,'Uwind','time','wind_time');
    ncwriteatt(CLMname,'Uwind','units','meter second-1');
    ncwriteatt(CLMname,'Uwind','coordinates','lon lat wind_time');

    ncwriteatt(CLMname,'Vwind','long_name','surface v-wind component');
    ncwriteatt(CLMname,'Vwind','time','wind_time');
    ncwriteatt(CLMname,'Vwind','units','meter second-1');
    ncwriteatt(CLMname,'Vwind','coordinates','lon lat wind_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'Uwind',Uwind);
    ncwrite(CLMname,'Vwind',Vwind);
    ncwrite(CLMname,'wind_time',wind_time);

    %swad
    CLMname = ['useast_swrad_era_',num2str(yyyy),'.nc'];
    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'srf_time','Dimensions',{'srf_time',nn});
    ncwriteatt(CLMname,'srf_time','units','days since 1858-11-17 00:00:00');
    ncwriteatt(CLMname,'srf_time','long_name','shortwave radiation flux time');

    nccreate(CLMname,'swrad','Dimensions',{'lon',xx,'lat',yy,'srf_time',nn});
    ncwriteatt(CLMname,'swrad','time','srf_time');
    ncwriteatt(CLMname,'swrad','long_name','solar shortwave radiation flux');
    ncwriteatt(CLMname,'swrad','units','Watt meter-2');
    ncwriteatt(CLMname,'swrad','coordinates','lon lat srf_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'swrad',swrad);
    ncwrite(CLMname,'srf_time',srf_time);

    %lwad
    CLMname = ['useast_lwrad_era_',num2str(yyyy),'.nc'];

    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'lrf_time','Dimensions',{'lrf_time',nn});
    ncwriteatt(CLMname,'lrf_time','units','days since 1858-11-17 00:00:00');
    ncwriteatt(CLMname,'lrf_time','long_name','longwave radiation flux time');

    nccreate(CLMname,'lwrad_down','Dimensions',{'lon',xx,'lat',yy,'lrf_time',nn});
    ncwriteatt(CLMname,'lwrad_down','time','lrf_time');
    ncwriteatt(CLMname,'lwrad_down','long_name','longwave radiation flux');
    ncwriteatt(CLMname,'lwrad_down','units','Watt meter-2');
    ncwriteatt(CLMname,'lwrad_down','coordinates','lon lat lrf_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'lwrad_down',lwrad_down);
    ncwrite(CLMname,'lrf_time',lrf_time);

    %rain
    CLMname = ['useast_rain_era_',num2str(yyyy),'.nc'];

    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'rain_time','Dimensions',{'rain_time',nn});
    ncwriteatt(CLMname,'rain_time','units','days since 1858-11-17 00:00:00');
    ncwriteatt(CLMname,'rain_time','long_name','rain fall time');

    nccreate(CLMname,'rain','Dimensions',{'lon',xx,'lat',yy,'rain_time',nn});
    ncwriteatt(CLMname,'rain','time','rain_time');
    ncwriteatt(CLMname,'rain','long_name','rain fall');
    ncwriteatt(CLMname,'rain','units','kilogram meter-2 second-1');
    ncwriteatt(CLMname,'rain','coordinates','lon lat rain_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'rain',rain);
    ncwrite(CLMname,'rain_time',rain_time);

    %Tair
    CLMname = ['useast_Tair_era_',num2str(yyyy),'.nc'];

    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'Tair_time','Dimensions',{'Tair_time',nn});
    ncwriteatt(CLMname,'Tair_time','units','days since 1858-11-17 00:00:00');
    ncwriteatt(CLMname,'Tair_time','long_name','surface air temperature time');

    nccreate(CLMname,'Tair','Dimensions',{'lon',xx,'lat',yy,'Tair_time',nn});
    ncwriteatt(CLMname,'Tair','time','Tair_time');
    ncwriteatt(CLMname,'Tair','long_name','surface air temperature');
    ncwriteatt(CLMname,'Tair','units','Celsius');
    ncwriteatt(CLMname,'Tair','coordinates','lon lat Tair_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'Tair',Tair);
    ncwrite(CLMname,'Tair_time',Tair_time);

    %Pair
    CLMname = ['useast_Pair_era_',num2str(yyyy),'.nc'];

    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'Pair_time','Dimensions',{'Pair_time',nn});
    ncwriteatt(CLMname,'Pair_time','units','days since 1858-11-17 00:00:00');
    ncwriteatt(CLMname,'Pair_time','long_name','surface air pressure time');

    nccreate(CLMname,'Pair','Dimensions',{'lon',xx,'lat',yy,'Pair_time',nn});
    ncwriteatt(CLMname,'Pair','time','Pair_time');
    ncwriteatt(CLMname,'Pair','long_name','surface air pressure');
    ncwriteatt(CLMname,'Pair','units','millibar');
    ncwriteatt(CLMname,'Pair','coordinates','lon lat Pair_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'Pair',Pair);
    ncwrite(CLMname,'Pair_time',Pair_time);

    %Qair
    CLMname = ['useast_Qair_era_',num2str(yyyy),'.nc'];

    nccreate(CLMname,'lon','Dimensions',{'lon',xx,'lat',yy});
    nccreate(CLMname,'lat','Dimensions',{'lon',xx,'lat',yy});

    nccreate(CLMname,'Qair_time','Dimensions',{'Qair_time',nn});
    ncwriteatt(CLMname,'Qair_time','units','days since 1858-11-17 00:00:00');
    ncwriteatt(CLMname,'Qair_time','long_name','surface air humidity time');

    nccreate(CLMname,'Qair','Dimensions',{'lon',xx,'lat',yy,'Qair_time',nn});
    ncwriteatt(CLMname,'Qair','time','Qair_time');
    ncwriteatt(CLMname,'Qair','long_name','surface air relative humidity');
    ncwriteatt(CLMname,'Qair','units','percentage');
    ncwriteatt(CLMname,'Qair','coordinates','lon lat Qair_time');

    ncwrite(CLMname,'lon',lon);
    ncwrite(CLMname,'lat',lat);
    ncwrite(CLMname,'Qair',Qair);
    ncwrite(CLMname,'Qair_time',Qair_time);
end
