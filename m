From: "lioupayphone" <lioupayphone@gmail.com>
Subject: Re: Re: what's the real meaning of fsid?
Date: Thu, 18 Dec 2008 09:16:22 +0800
Message-ID: <200812180916175465416@gmail.com>
References: <200812171336070316863@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
To: "Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:30034 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbYLRBQb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 20:16:31 -0500
Received: by ti-out-0910.google.com with SMTP id b6so58350tic.23
        for <linux-nfs@vger.kernel.org>; Wed, 17 Dec 2008 17:16:29 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Steve Dickson.
you wrote about "Re: what's the real meaning of fsid?" at 06:34:20 on 2008-12-18 :
thank you for your attentions. and i did a retry. the results were listed below.
>
>
>lioupayphone wrote:
>> Hello, everyone. 
>> 
>> fsid in /etc/exports was used for identifying a file system. if a file system which exported 2 directories, it seems that we should tag the two export entries with same fsid.
>> 
>> eg
>> on one machine (server   10.10.37.147,  Centos5.2 with linux2.6.18):
>> 
>> #mkfs.ext3 /dev/sdc; mount /dev/sdc /mnt/;mkdir -p /mnt/dir1 /mnt/dir2; touch /mnt/dir1/wall-e /mnt/dir2/eva;
>> #echo "/mnt/dir1 *(rw,async,root_squash,fsid=2)" > /etc/exports
>> #echo "/mnt/dir2 *(rw,async,root_squash,fsid=2)" >> /etc/exports
>> #service nfs start && exportfs -r
>> 
>> on another machine (client   10.10.37.154):
>> #mount  10.10.37.147:/mnt/dir1 /mnt/1/ && mount 10.10.37.147:/mnt/dir2 /mnt/2/
>> 
>> i am puzzled:   on the client (10.10.37.154), i found both "/mnt/1/" and "/mnt/2/" have the same child ---- "wall-e".
>> 
>> so i browsed the code of 2.6.18 and found: exp_export(), fs/nfsd/export.c . i have taged a comment on this code listed below. please give me some suggestions. thx.
>I'm a bit puzzled by "both "/mnt/1/" and "/mnt/2/" have the same child". 
>Do mean they have the same file handle??
>
>steved.
>
yes, both the two directories have a same FH.
when i "cat /proc/fs/nfsd/exports ", it shows :
# Version 1.1
# Path Client(Flags) # IPs
/mnt/dir1       *(rw,root_squash,async,wdelay,no_subtree_check,fsid=2)
/mnt/dir2       *(rw,root_squash,async,wdelay,no_subtree_check,fsid=2) 

and i "rpc.mountd -d all", and try do mount on client: 
	mount -t nfs -o nolock 10.10.37.147:/mnt/dir1 /mnt/1/; 
	mount -t nfs -o nolock 10.10.37.147:/mnt/dir2 /mnt/2/;

the log on server (/var/log/messages) shows:

Dec 18 09:06:37 nike mountd[21018]: MNT3(/mnt/dir1) called
Dec 18 09:06:37 nike mountd[21018]: authenticated mount request from 10.10.37.154:981 for /mnt/dir1 (/mnt/dir1)
Dec 18 09:06:43 nike mountd[21018]: MNT3(/mnt/dir1) called
Dec 18 09:06:43 nike mountd[21018]: authenticated mount request from 10.10.37.154:983 for /mnt/dir1 (/mnt/dir1)
Dec 18 09:06:43 nike mountd[21018]: nfsd_fh: inbuf '* 1 \x02000000'
Dec 18 09:06:43 nike mountd[21018]: /mnt/dir1 and /mnt/dir2 have same filehandle for *, using first
Dec 18 09:06:43 nike mountd[21018]: nfsd_fh: found 0x2ac56363a0b0 path /mnt/dir1
Dec 18 09:06:50 nike mountd[21018]: MNT3(/mnt/dir2) called
Dec 18 09:06:50 nike mountd[21018]: authenticated mount request from 10.10.37.154:986 for /mnt/dir2 (/mnt/dir2)

in kernel, /mnt/dir1 and /mnt/dir2 respectively corresponds to   two different svc_export objects. 
in fh_compose(), they have same fsid_type and fsid, but the fileidtype and fileid should NOT be same.
i am still in puzzled. :-(

btw : "nike" is the hostname of server. :-)




Best Regards!
lioupayphone

