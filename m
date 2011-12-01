Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:55006 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab1LAFHg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 00:07:36 -0500
Received: by yenl6 with SMTP id l6so1322296yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Nov 2011 21:07:35 -0800 (PST)
Message-ID: <4ED70B93.8070705@gmail.com>
Date: Wed, 30 Nov 2011 23:07:31 -0600
From: Bruce Dubbs <bruce.dubbs@gmail.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Subject: Re: nfs server issues
References: <4ED6BCEA.9050000@gmail.com> <20111201024319.GA10246@umich.edu> <4ED704E5.2030500@gmail.com>
In-Reply-To: <4ED704E5.2030500@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The parent should have gone to the list.

Bruce Dubbs wrote:
> Jim Rees wrote:
>> Bruce Dubbs wrote:
>>
>>   I am trying to document the installation of nfs for Linux From
>>   Scratch.  The client works, but the server does not and I'm looking
>>   for some help.   If this is the wrong place to ask for help, please
>>   redirect me.
>>     For now, I am only trying to get nfs version 3 to work.
>>     # mount -t nfs -o nfsvers=3 lfs6:/home/bdubbs /mnt/test
>>      [ mounts OK ]
>>   # mount -t nfs -o nfsvers=3 localhost:/usr/src /mnt/tmp
>>   # mount.nfs: requested NFS version or transport protocol is not 
>> supported
>>
>> It doesn't explain the error message you're getting, but your exports 
>> file
>> doesn't have an entry for localhost.  When I try this I get "mount.nfs:
>> access denied by server while mounting localhost:/usr/src".
> 
> I added
> /usr/src 127.0.0.0/8(rw,async,no_root_squash,subtree_check)
> 
> but still got 'requested NFS version or transport protocol is not 
> supported'.  I suspect it has something to do with rpcbind not having 
> nfsd registered on port 2049.  At least rpcinfo doesn't know about it.
> 
>>   2. Build libtirpc
>>      Remove auth_des.c authdes_prot.c des_crypt.c from Makefile
>>      Comment out authdes_create() in rpc_soc.c
>>      ./configure --prefix=/usr --libdir=/lib
>>
>> This shouldn't be necessary.  Instead of working around the problem, it
>> would be nice if you could figure out why you needed to do this, and if
>> there is a bug in the configure magic, let us know.
> 
> Which shouldn't be necessary?   The change to the Makefile/rpc_soc.c 
> files or the -prefix and --libdir options?
> 
> I just went back and rebuilt without the file changes and it built fine. 
> I'm not sure what happened to change it, but it was definitely needed 
> before.  Sometimes when you are building a whole system from scratch, 
> some assumed prereqs are not installed.  I'll have to figure that out to 
> get it right.  I suspect it was because I originally didn't get the 
> replacement of the rpc/nis headers that glibc now omits installed 
> correctly.

Now I remember.  Without the patch, other programs don't link.  For 
example, rpcbind gives:

  gcc -g -O2 -o rpcbind check_bound.o rpcbind.o rpcb_svc_4.o 
rpcb_svc_com.o util.o pmap_svc.o rpcb_stat.o rpcb_svc.o security.o 
warmstart.o  /lib/libtirpc.so -lnsl -lpthread   -Wl,--rpath -Wl,/lib 
-Wl,--rpath -Wl,/lib
/lib/libtirpc.so: undefined reference to `key_encryptsession_pk'
/lib/libtirpc.so: undefined reference to `getnetname'
/lib/libtirpc.so: undefined reference to `_des_crypt_call'
/lib/libtirpc.so: undefined reference to `getpublickey'
/lib/libtirpc.so: undefined reference to `key_gendes'

This is a glibc-2.14 and later issue.

> As for the --prefix and --libdir options, we may not need the --prefix. 
> Most packages install in /usr/local without it.  The --libdir is to 
> install in /lib instead of /usr/lib so the library is available if /usr 
> is not mounted.  Without the setting, we would have to move the files 
> and also modify the libdir line in both libtirpc.la and libtirpc.pc.
> 
>   -- Bruce
> 

