Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44744 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932420Ab1LEPwh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Dec 2011 10:52:37 -0500
Message-ID: <4EDCE8B2.1050702@RedHat.com>
Date: Mon, 05 Dec 2011 10:52:18 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Anibal Monsalve Salazar <anibal@debian.org>
CC: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
        Michael Rasmussen <mir@datanom.net>, 651032@bugs.debian.org
Subject: Re: Bug#651032: /usr/sbin/rpc.idmapd: rpc.idmapd referring to none
 existing library
References: <20111205071808.5626.67399.reportbug@sleipner.datanom.net> <20111205082520.GA5890@debian.org>
In-Reply-To: <20111205082520.GA5890@debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,


On 12/05/2011 03:25 AM, Anibal Monsalve Salazar wrote:
> Hello Steve and Kevin,
> 
> To fix Debian Bug#649491[1], I moved the .so files to /lib and applied
> the following patch:
> 
> --- a/libnfsidmap.c	2010-12-09 04:07:53.000000000 +1100
> +++ b/libnfsidmap.c	2011-12-05 11:23:46.000000000 +1100
> @@ -61,7 +61,7 @@ static struct mapping_plugin **nfs4_plug
>  static struct mapping_plugin **gss_plugins = NULL;
>  
>  #ifndef PATH_PLUGINS
> -#define PATH_PLUGINS "/usr/lib/libnfsidmap"
> +#define PATH_PLUGINS "/lib/libnfsidmap"
>  #endif
>  #define PLUGIN_INIT_FUNC "libnfsidmap_plugin_init"
>  
> [1] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=649491
Why not just use the --with-pluginpath configuration flag?
That's how we do it in Fedora...

steved.

> 
> As Michael reported, libnfsidmap is still looking for the plugins in
> /usr/lib/libnfsidmap.
> 
> What do I need to change in libnfsidmap to make it find the plugins in
> /lib/libnfsidmap?
> 
> Please see Michael's report below.
> 
> Cheers,
> 
> Anibal
> 
> As Michael has reported, libnfsidmap2 is still looking 
> On Mon, Dec 05, 2011 at 08:18:08AM +0100, Michael Rasmussen wrote:
>> Package: nfs-common
>> Version: 1:1.2.5-2+b1
>> Severity: grave
>> File: /usr/sbin/rpc.idmapd
>> Justification: renders package unusable
>>
>> rpc.idmapd -v
>> rpc.idmapd: libnfsidmap: using domain: midgaard
>>
>> rpc.idmapd: libnfsidmap: Unable to load plugin:
>> /usr/lib/libnfsidmap/nsswitch.so: cannot open shared object file: No
>> such file or directory
>>
>> rpc.idmapd: libnfsidmap: requested translation method, 'nsswitch', is
>> not available
>>
>> rpc.idmapd: Unable to create name to user id mappings.
>>
>> rpc.idmapd is searching for libnfsidmap plugins in the wrong directory
>> so bug #650904 must be reopen since the provided change made to
>> libnfsidmap2 does not make any difference rpc.idmapd still uses
>> /usr/lib/libnfsidmap.
>>
>>
>> -- Package-specific info:
>> -- rpcinfo --
>>    program vers proto   port  service
>>     100000    4   tcp    111  portmapper
>>     100000    3   tcp    111  portmapper
>>     100000    2   tcp    111  portmapper
>>     100000    4   udp    111  portmapper
>>     100000    3   udp    111  portmapper
>>     100000    2   udp    111  portmapper
>>     100007    2   udp    785  ypbind
>>     100007    1   udp    785  ypbind
>>     100007    2   tcp    786  ypbind
>>     100007    1   tcp    786  ypbind
>> -- /etc/default/nfs-common --
>> NEED_STATD=no
>> STATDOPTS=
>> NEED_IDMAPD=yes
>> NEED_GSSD=
>> -- /etc/idmapd.conf --
>> [General]
>> Verbosity = 0
>> Pipefs-Directory = /var/lib/nfs/rpc_pipefs
>> Domain = midgaard 
>> [Mapping]
>> Nobody-User = nobody
>> Nobody-Group = nogroup
>> -- /etc/fstab --
>> balder:/home	/home		nfs4	defaults,proto=tcp,retry=5,hard,intr,async,_netdev,rsize=32768,wsize=32768 0	0
>> -- /proc/mounts --
>> rpc_pipefs /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0
>> balder:/home/ /home nfs4 rw,relatime,vers=4,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.2.79,minorversion=0,local_lock=none,addr=192.168.2.2 0 0
>>
>> -- System Information:
>> Debian Release: wheezy/sid
>>   APT prefers unstable
>>   APT policy: (990, 'unstable'), (1, 'experimental')
>> Architecture: amd64 (x86_64)
>>
>> Kernel: Linux 3.1.0-1-amd64 (SMP w/2 CPU cores)
>> Locale: LANG=en_US, LC_CTYPE=en_US (charmap=ISO-8859-1)
>> Shell: /bin/sh linked to /bin/bash
>>
>> Versions of packages nfs-common depends on:
>> ii  adduser             3.113
>> ii  initscripts         2.88dsf-13.13
>> ii  libc6               2.13-21
>> ii  libcap2             1:2.22-1
>> ii  libcomerr2          1.42-1
>> ii  libdevmapper1.02.1  2:1.02.67-2
>> ii  libevent-2.0-5      2.0.16-stable-1
>> ii  libgssapi-krb5-2    1.10+dfsg~alpha1-6
>> ii  libgssglue1         0.3-3.1
>> ii  libk5crypto3        1.10+dfsg~alpha1-6
>> ii  libkeyutils1        1.5.2-2
>> ii  libkrb5-3           1.10+dfsg~alpha1-6
>> ii  libnfsidmap2        0.24-3
>> ii  libtirpc1           0.2.2-5
>> ii  libwrap0            7.6.q-21
>> ii  lsb-base            3.2-28
>> ii  rpcbind             0.2.0-6
>> ii  ucf                 3.0025+nmu2
>>
>> Versions of packages nfs-common recommends:
>> ii  python  2.7.2-9
>>
>> nfs-common suggests no packages.
>>
>> -- no debconf information
