Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34807 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbDPEnY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2015 00:43:24 -0400
Received: by pdbqa5 with SMTP id qa5so77728596pdb.1
        for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2015 21:43:23 -0700 (PDT)
Message-ID: <552F3DE2.4020603@gmail.com>
Date: Thu, 16 Apr 2015 12:43:14 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>, linux-nfs@vger.kernel.org
Subject: Re: Problem installing nfs-utils to non standard dir
References: <552E3508.5000403@fys.uio.no> <552E86A8.6080506@gmail.com> <552E9D80.1090003@fys.uio.no>
In-Reply-To: <552E9D80.1090003@fys.uio.no>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 4/16/2015 1:18 AM, Eino Juhani Oltedal wrote:
> Thank you for the help. I was able to avoid the error by using make DESTDIR=${HOME}/installs/arm
> instead of the prefix. Then i copied everything  under ${HOME}/installs/arm over to the root of the
> ARM file-system.
> 
> However when trying to use the newly built nfs I get some errors:
> 
> mount -t nfs 192.168.0.104:/test /mnt
>     mount.nfs: rpc.statd is not running but is required for remote locking.
>     mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
>     mount.nfs: an incorrect mount option was specified
> 
> mount -t nfs -o nolock 192.168.0.104:/test /mnt
>     mount.nfs: Protocol not supported
> 
> 
> showmount also gives an error:
>     showmount -e 192.168.0.104
>     clnt_create: RPC: Unknown protocol

Can you show me the rpcinfo messages, and exports entry?
# rpcinfo -p
# cat /etc/exports
# exportfs

thanks
Kinglong Mee

> 
> I compiled nfs using this command:
> 
>     cd ~/installs/util-linux-2.26.1
>     ./configure --host=arm-linux-gnueabihf --build=x86_64-linux --disable-gss --disable-nfsv4 CC=arm-linux-gnueabihf-gcc CPPFLAGS="-I${HOME}/installs/arm/include, -I${HOME}/installs/arm/usr/include" LDFLAGS="-L${HOME}/installs/arm/lib/, -L${HOME}/installs/arm/usr/lib/"
>     make
>     make DESTDIR=${HOME}/installs/arm install
> 
> I compiled the dependencies libblkid and libtirpc with the following commands:
> 
>     cd ~/installs/util-linux-2.26.1
>     ./configure --host=arm-linux-gnueabihf --disable-all-programs --enable-libblkid --build=x86_64-linux CC=arm-linux-gnueabihf-gcc
>     make
>     make DESTDIR=${HOME}/installs/arm install
> 
>     cd ~/installs/libtirpc-0.2.5
>     ./configure  --host=arm-linux-gnueabihf --build=x86_64-linux --disable-gssapi CC=arm-linux-gnueabihf-gcc
>     make
>     make DESTDIR=${HOME}/installs/arm install
> 
> Here is my build file tree:
> 
> $HOME/installs/arm
> ├── bin
> ├── lib
> │   ├── libblkid.so.1 -> libblkid.so.1.1.0
> │   └── libblkid.so.1.1.0
> ├── sbin
> │   ├── mount.nfs
> │   ├── mount.nfs4 -> mount.nfs
> │   ├── osd_login
> │   ├── umount.nfs -> mount.nfs
> │   └── umount.nfs4 -> mount.nfs
> ├── usr
> │   ├── bin
> │   ├── etc
> │   │   └── netconfig
> │   ├── include
> │   │   ├── blkid
> │   │   │   └── blkid.h
> │   │   └── tirpc
> │   │       ├── netconfig.h
> │   │       ├── rpc
> │   │       │   ├── auth_des.h
> │   │       │   ├── auth_gss.h
> │   │       │   ├── auth.h
> │   │       │   ├── auth_kerb.h
> │   │       │   ├── auth_unix.h
> │   │       │   ├── clnt.h
> │   │       │   ├── clnt_soc.h
> │   │       │   ├── clnt_stat.h
> │   │       │   ├── des_crypt.h
> │   │       │   ├── des.h
> │   │       │   ├── nettype.h
> │   │       │   ├── pmap_clnt.h
> │   │       │   ├── pmap_prot.h
> │   │       │   ├── pmap_rmt.h
> │   │       │   ├── raw.h
> │   │       │   ├── rpcb_clnt.h
> │   │       │   ├── rpcb_prot.h
> │   │       │   ├── rpcb_prot.x
> │   │       │   ├── rpc_com.h
> │   │       │   ├── rpcent.h
> │   │       │   ├── rpc.h
> │   │       │   ├── rpc_msg.h
> │   │       │   ├── svc_auth.h
> │   │       │   ├── svc_dg.h
> │   │       │   ├── svc.h
> │   │       │   ├── svc_soc.h
> │   │       │   ├── types.h
> │   │       │   └── xdr.h
> │   │       └── rpcsvc
> │   │           ├── crypt.h
> │   │           └── crypt.x
> │   ├── lib
> │   │   ├── libblkid.a
> │   │   ├── libblkid.la
> │   │   ├── libblkid.so -> ../../lib/libblkid.so.1.1.0
> │   │   ├── libtirpc.a
> │   │   ├── libtirpc.la
> │   │   ├── libtirpc.so -> libtirpc.so.1.0.10
> │   │   ├── libtirpc.so.1 -> libtirpc.so.1.0.10
> │   │   ├── libtirpc.so.1.0.10
> │   │   ├── pkgconfig
> │   │   │   ├── blkid.pc
> │   │   │   └── libtirpc.pc
> │   │   └── systemd
> │   │       └── system
> │   ├── sbin
> │   │   ├── exportfs
> │   │   ├── mountstats
> │   │   ├── nfsiostat
> │   │   ├── nfsstat
> │   │   ├── rpcdebug
> │   │   ├── rpc.mountd
> │   │   ├── rpc.nfsd
> │   │   ├── rpc.statd
> │   │   ├── showmount
> │   │   ├── sm-notify
> │   │   └── start-statd
> │   └── share
> │       ├── bash-completion
> │       │   └── completions
> │       ├── locale
> │       │   ├── ca
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── cs
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── da
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── de
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── es
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── et
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── eu
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── fi
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── fr
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── gl
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── hr
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── hu
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── id
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── it
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── ja
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── nl
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── pl
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── pt_BR
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── ru
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── sl
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── sv
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── tr
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── uk
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── vi
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   ├── zh_CN
> │       │   │   └── LC_MESSAGES
> │       │   │       └── util-linux.mo
> │       │   └── zh_TW
> │       │       └── LC_MESSAGES
> │       │           └── util-linux.mo
> │       └── man
> │           ├── man1
> │           ├── man3
> │           │   ├── bindresvport.3t
> │           │   ├── des_crypt.3t
> │           │   ├── getnetconfig.3t
> │           │   ├── getnetpath.3t
> │           │   ├── getrpcent.3t
> │           │   ├── getrpcport.3t
> │           │   ├── libblkid.3
> │           │   ├── rpc.3t
> │           │   ├── rpcbind.3t
> │           │   ├── rpc_clnt_auth.3t
> │           │   ├── rpc_clnt_calls.3t
> │           │   ├── rpc_clnt_create.3t
> │           │   ├── rpc_secure.3t
> │           │   ├── rpc_soc.3t
> │           │   ├── rpc_svc_calls.3t
> │           │   ├── rpc_svc_create.3t
> │           │   ├── rpc_svc_err.3t
> │           │   ├── rpc_svc_reg.3t
> │           │   ├── rpc_xdr.3t
> │           │   └── rtime.3t
> │           ├── man5
> │           │   ├── exports.5
> │           │   ├── netconfig.5
> │           │   ├── nfs.5
> │           │   ├── nfsmount.conf.5
> │           │   └── terminal-colors.d.5
> │           ├── man7
> │           │   └── nfsd.7
> │           └── man8
> │               ├── exportfs.8
> │               ├── mountd.8
> │               ├── mount.nfs.8
> │               ├── mountstats.8
> │               ├── nfsd.8
> │               ├── nfsiostat.8
> │               ├── nfsstat.8
> │               ├── rpcdebug.8
> │               ├── rpc.mountd.8 -> mountd.8
> │               ├── rpc.nfsd.8 -> nfsd.8
> │               ├── rpc.sm-notify.8 -> sm-notify.8
> │               ├── rpc.statd.8 -> statd.8
> │               ├── showmount.8
> │               ├── sm-notify.8
> │               ├── statd.8
> │               └── umount.nfs.8
> └── var
>     └── lib
>         └── nfs
>             ├── etab
>             ├── rmtab
>             ├── sm
>             ├── sm.bak
>             ├── state
>             └── xtab
> 
> 
> Do you have any idea what's missing? Maybe some dependencies?
> 
> Cheers,
> Eino
> 
> On 04/15/2015 05:41 PM, Kinglong Mee wrote:
>> On 4/15/2015 5:53 PM, Eino Juhani Oltedal wrote:
>>> Hi!
>>>
>>> I'm trying to build nfs from source. I'm using nfs-utils-1.3.2 from http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.2/.
>>> I configure using the following command
>>>
>>>      ./configure --prefix=/home/username/installs/tmp --exec-prefix=/home/username/installs/tmp
>>>
>>> When i run "make install" most of the packages are put under /home/username/installs/tmp, but for some reason the
>>> install script tries to put osd_login under /sbin, which results in an error:
>>>
>>>      Making install in osd_login
>>>      make[2]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>>>      make[3]: Entering directory `/home/username/installs/nfs-utils-1.3.2/utils/osd_login'
>>>          /usr/bin/mkdir -p '/sbin'
>>>          /usr/bin/install -c osd_login '/sbin'
>>>          /usr/bin/install: cannot remove ‘/sbin/osd_login’: Permission denied
>>>          make[3]: *** [install-dist_sbinSCRIPTS] Error 1
>>>
>>> This is not supposed to happen, is it?
>> No, it is.
>> There are three utils (mount.nfs/mount.nfs4, nfsdcltrack and osd_login)
>> must be installed in directory /sbin/, they are hard-coded.
>>
>>> Is there an easy way to fix it? I get the same error trying to build nfs-utils-1.3.1 as well.
>> No, they are must installed in /sbin/ for kernel module nfsd.ko needing
>> /sbin/nfsdcltrack and objlayoutdriver.ko needing /sbin/osd_login.
>>
>> You can not skip this problem with recently source.
>> if you are hurry， you can avoid this problem with the following patch and configure as,
>>
>> # ./configure --disable-mount --disable-nfsdcltrack --disable-osdlogin --prefix=/root/test --exec-prefix=/root/test/
>>
>> Ps: It is just a draft made by diff. I will send some patches for this problem.
>>
>> thanks,
>> Kinglong Mee
>>
>> ===================================================================
>> diff --git a/configure.ac b/configure.ac
>> index e61430f..294e7a3 100644
>> --- a/configure.ac
>> +++ b/configure.ac
>> @@ -213,9 +213,16 @@ fi
>>   AC_ARG_ENABLE(nfsdcltrack,
>>       [AC_HELP_STRING([--disable-nfsdcltrack],
>>               [disable NFSv4 clientid tracking programs @<:@default=no@:>@])],
>> -    enable_nfsdctrack=$enableval,
>> +    enable_nfsdcltrack=$enableval,
>>       enable_nfsdcltrack="yes")
>>   +AC_ARG_ENABLE(osdlogin,
>> +    [AC_HELP_STRING([--disable-osdlogin],
>> +            [disable osd_login scripts @<:@default=no@:>@])],
>> +    enable_osdlogin=$enableval,
>> +    enable_osdlogin="yes")
>> +    AM_CONDITIONAL(CONFIG_OSD_LOGIN, [test "$enable_osdlogin" = "yes" ])
>> +
>>   dnl Check for TI-RPC library and headers
>>   AC_LIBTIRPC
>>   @@ -346,7 +353,7 @@ AC_SUBST(LIBBSD)
>>   AC_SUBST(LIBBLKID)
>>   AC_SUBST(LIBDL)
>>   -if test "$enable_libmount" != no; then
>> +if test "$enable_libmount" = yes; then
>>      AC_CHECK_LIB(mount, mnt_context_do_mount, [LIBMOUNT="-lmount"], AC_MSG_ERROR([libmount needed]))
>>      AC_CHECK_HEADER(libmount/libmount.h, , AC_MSG_ERROR([Cannot find libmount header file libmount/libmount.h]))
>>   fi
>> diff --git a/utils/Makefile.am b/utils/Makefile.am
>> index b892dc8..6dd4a57 100644
>> --- a/utils/Makefile.am
>> +++ b/utils/Makefile.am
>> @@ -25,6 +25,10 @@ if CONFIG_NFSDCLTRACK
>>   OPTDIRS += nfsdcltrack
>>   endif
>>   +if CONFIG_OSD_LOGIN
>> +OPTDIRS += osd_login
>> +endif
>> +
>>   SUBDIRS = \
>>       exportfs \
>>       mountd \
>> @@ -32,7 +36,6 @@ SUBDIRS = \
>>       nfsstat \
>>       showmount \
>>       statd \
>> -    osd_login \
>>       $(OPTDIRS)
>>     MAINTAINERCLEANFILES = Makefile.in
> 
> 
