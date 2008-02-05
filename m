From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 01/10] NFS: Always enable NFS direct I/O
Date: Wed, 06 Feb 2008 10:26:05 +1100
Message-ID: <47A8F08D.80502@melbourne.sgi.com>
References: <20080205180836.32229.61375.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:44098 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755083AbYBEXT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 18:19:28 -0500
In-Reply-To: <20080205180836.32229.61375.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Since O_DIRECT is a standard feature that is enabled in most distros,
> eliminate the CONFIG_NFS_DIRECTIO build option, and change the
> fs/nfs/Makefile to always build in the NFS direct I/O engine.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   

Looks good to me.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

