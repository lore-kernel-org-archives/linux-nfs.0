From: Stefan Egli <stefan.egli@gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Fri, 21 Aug 2009 21:08:01 +0200
Message-ID: <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:60897 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688AbZHUTIA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 15:08:00 -0400
Received: by fxm17 with SMTP id 17so618470fxm.37
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2009 12:08:01 -0700 (PDT)
In-Reply-To: <1250880591.27154.18.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

> It sounds like a bug. You don't mention which client you are using.

from uname:
Linux (Ubuntu) 2.6.24-24-generic #1 SMP Tue Jun 30 19:54:36 UTC 2009
x86_64 GNU/Linux

from mount:
type nfs (ro,tcp,rsize=3D8192,wsize=3D8192,nfsvers=3D3,addr=3D192.168.X=
X.YY)

> You can tune the amount of time the client caches information by usin=
g
> the 'ac*' mount options. In this case, you will want to adjust the
> values of 'acdirmin' and 'acdirmax', probably setting them to zero.
>
> 'man 5 nfs' should provide you with more information.

Ok, so setting acdirmin=3D0 and acdirmax=3D0 would mean no directory
content caching, right?

>> =A0Question 4: If we'd somehow manually detected such a directory
>> content inconsistency - would there be something like a 'hey NFS
>> client, flush all NFS caches NOW' thing?
>
> No.

unmount / mount would - but that's obviously not feasible. bugger
there's nothing for that...

>> =A0Question 5: any of this related to commit 37d9d76d8b3a2ac5817e1fa=
3263cfe
>> 0fdb439e51: NFS: flush cached directory information slightly more re=
adily. ?
>
> You client should be seeing mtime changes when you are creating new
> files, so it shouldn't need to look at the ctime.
>
> The only time when ctime changes are relevant are if you use 'rsync' =
to
> copy the files without specifying --omit-dir-times.
> IOW: if something is explicitly setting the mtime on the directory.

Would have to check if that applies in our case. We're doing
backup/restore from tivoli (tsm) - maybe that guy is to be blamed
for not correctly updating mtime/ctimes ?

Cheers,
Stefan
