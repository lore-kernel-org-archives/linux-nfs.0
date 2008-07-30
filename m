From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount.nfs command: old glibc missing some flags
Date: Wed, 30 Jul 2008 14:02:24 -0400
Message-ID: <76bd70e30807301102y79c40098x85308aa4af50e87f@mail.gmail.com>
References: <20080729161512.7588.18445.stgit@manray.1015granger.net>
	 <x6y73jyiek@gzp>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>, "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:1125 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbYG3SC1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2008 14:02:27 -0400
Received: by mu-out-0910.google.com with SMTP id w8so133046mue.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2008 11:02:25 -0700 (PDT)
In-Reply-To: <x6y73jyiek@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 30, 2008 at 2:50 AM, Gabor Z. Papp <gzp-2g/1Y3AqmNE@public.gmane.org> wrote:
> | Untested.  Gabor, can you please try this?
>
> Compiled fine.

Excellent, thanks for testing.

> utils/mountd/Makefile:
>
> LIBBLKID = -lblkid
>
> -lblkid doesn't enough in dependency, needs -luuid
>
> Is this problem in my e2fsprogs install?

This one I'm not an expert on, but it seems to me you might find some
relevant information by searching the archives of the linux-nfs
mailing list over the past year.

I thought libuuid was already called out in configure.ac, but I could
be completely wrong about that.

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

That might take some debugging.  There were some last minute changes
to sm-notify before 1.1.3 was released.

-- 
Chuck Lever
