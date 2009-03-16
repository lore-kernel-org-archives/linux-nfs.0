From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/9] Address type width mismatches between TI-RPC and
 glibc
Date: Mon, 16 Mar 2009 13:44:40 -0400
Message-ID: <49BE9008.7030101@RedHat.com>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56928 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbZCPRr2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2009 13:47:28 -0400
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Steve-
> 
> Now that the clean up is finished, here are the patches that actually
> fix the type width mismatch problem between glibc headers and the
> TI-RPC run-time.
> 
> This patch set implements a full switch between TI-RPC run-time and
> headers and legacy glibc RPC run-time and headers via --enable-tirpc.
> 
> In addition there are a number of configure.ac clean ups.
> 
> These are the final patches needed to support TI-RPC and IPv6 properly
> in mount.nfs, umount.nfs, and showmount.
> 
> ---
> 
> Chuck Lever (7):
>       nfs-utils: Include legacy or TI-RPC headers, not both
>       configure: move IPv6 feature checks into aclocal/
>       configure: Move rpcsecgss checking into aclocal
>       configure: pull common nfsidmap and event checks into aclocal/
>       nfs-utils: replace function-specific switches with HAVE_LIBTIRPC
>       configure: move TI-RPC checks into aclocal/
>       configure: add defensive quoting in some function checks
> 
> Jeff Layton (2):
>       nfs-utils: clean up handling of libgssglue in gssd Makefile
>       nfs-utils: don't need extra libs to do AC_CHECK_LIBS for librpcsecgss
> 
committed...

steved.
