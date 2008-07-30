From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs command: old glibc missing some flags
Date: Wed, 30 Jul 2008 15:00:06 -0400
Message-ID: <4890BA36.1060802@RedHat.com>
References: <20080729161512.7588.18445.stgit@manray.1015granger.net> <x6y73jyiek@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506AbYG3TBk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 15:01:40 -0400
In-Reply-To: <x6y73jyiek@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Gabor Z. Papp wrote:
> * Chuck Lever <chuck.lever@oracle.com>:
> 
> | Untested.  Gabor, can you please try this?
> 
> Compiled fine.
> 
> utils/mountd/Makefile:
> 
> LIBBLKID = -lblkid
> 
> -lblkid doesn't enough in dependency, needs -luuid
> 
> Is this problem in my e2fsprogs install?
At least in my world you also need the e2fsprogs-devel package
installed as well...

> 
> BTW, I'm not sure about usage of sm-notify
> 
> My nfs startup script looks like:
> 
> idmapd
> exportfs -ar
> mountd
> statd #--no-notify
> nfsd 8
> 
> $ ps fax
> 10860 ?        Ss     0:00 mountd
> 10862 ?        Ss     0:00 statd
> 10875 ?        S      0:00 [nfsd]
> 10876 ?        S      0:00 [nfsd]
> 10886 ?        S      0:00 [lockd]
> 10887 ?        S      0:00  \_ [rpciod]
> 10888 ?        S      0:00 [nfsd]
> 10889 ?        S      0:00 [nfsd]
> 10890 ?        S      0:00 [nfsd]
> 10891 ?        S      0:00 [nfsd]
> 10892 ?        S      0:00 [nfsd]
> 10893 ?        S      0:00 [nfsd]
> 
> Looks like no sm-notify started, even I mount something from a remote
> host. If I start sm-notify by hand, it exist, strace output attached.
> Same apply on glibc 2.3.
Note that sm-notify is a very short lived process.... 

If have found using the -d flag is very handy when starting sm-notify 
by hand... If there is no output, it means the /var/run/sm-notify.pid exists
which causes sm-notify to immediately exit. So remove that file and try 
again... 

In general, if there are file(s) in /var/lib/nfs/sm (or /var/lib/nfs/statd/sm 
depending on your distro) means sm-notify did not work. With Fedora, doing 
a 'service nfslock restart' will cause sm-notify to be rerun... I'm not 
sure how to do that with other distros... 

steved.


 

