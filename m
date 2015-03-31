Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:50351 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755067AbbCaQg4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 12:36:56 -0400
Date: Tue, 31 Mar 2015 18:36:53 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] sunrpc: make debugfs file creation failure non-fatal
Message-ID: <20150331163653.GA14322@kroah.com>
References: <1427817808-21732-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427817808-21732-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 12:03:28PM -0400, Jeff Layton wrote:
> v2: gracefully handle the case where some dentry pointers end up NULL
>     and be more dilligent about zeroing out dentry pointers
> 
> We currently have a problem that SELinux policy is being enforced when
> creating debugfs files. If a debugfs file is created as a side effect of
> doing some syscall, then that creation can fail if the SELinux policy
> for that process prevents it.
> 
> This seems wrong. We don't do that for files under /proc, for instance,
> so Bruce has proposed a patch to fix that.
> 
> While discussing that patch however, Greg K.H. stated:
> 
>     "No kernel code should care / fail if a debugfs function fails, so
>      please fix up the sunrpc code first."
> 
> This patch converts all of the sunrpc debugfs setup code to be void
> return functins, and the callers to not look for errors from those
> functions.
> 
> This should allow rpc_clnt and rpc_xprt creation to work, even if the
> kernel fails to create debugfs files for some reason.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Acked-by: "J. Bruce Fields" <bfields@fieldses.org>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  include/linux/sunrpc/debug.h | 18 +++++++--------
>  net/sunrpc/clnt.c            |  4 +---
>  net/sunrpc/debugfs.c         | 52 ++++++++++++++++++++++++--------------------
>  net/sunrpc/sunrpc_syms.c     |  7 +-----
>  net/sunrpc/xprt.c            |  7 +-----
>  5 files changed, 41 insertions(+), 47 deletions(-)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
