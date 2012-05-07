Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64811 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544Ab2EGIyZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 04:54:25 -0400
Date: Mon, 7 May 2012 10:54:19 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, chuck.lever@oracle.com, linux@razik.name,
        Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu
Subject: Re: [PATCH] init: don't try mounting device as nfs root unless type
 fully matches
Message-ID: <20120507085419.GN16608@gmail.com>
References: <1336230395-5215-1-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336230395-5215-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Sasha Levin <levinsasha928@gmail.com> wrote:

> Currently, we'll try mounting any device who's major device number is
> UNNAMED_MAJOR as NFS root. This would happen for non-NFS devices as well (such
> as 9p devices) but it wouldn't cause any issues since mounting the device
> as NFS would fail quickly and the code proceeded to doing the proper mount:
> 
>        [  101.522716] VFS: Unable to mount root fs via NFS, trying floppy.
>        [  101.534499] VFS: Mounted root (9p filesystem) on device 0:18.
> 
> Commit 6829a048 ("NFS: Retry mounting NFSROOT") has introduced retries when
> mounting NFS root, which means that now we don't immediately fail and instead
> it takes an additional 90+ seconds until we stop retrying, which has revealed
> the issue this patch fixes.

Just wondering, which tree is commit 6829a048 included in? It 
does not appear to be mainline AFAICS.

Thanks,

	Ingo
