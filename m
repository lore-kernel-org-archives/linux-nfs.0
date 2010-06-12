From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 00/26] LAYOUT invocation v2
Date: Sat, 12 Jun 2010 23:35:55 +0300
Message-ID: <4C13EFAB.4070104@panasas.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63908 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752221Ab0FLUf7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jun 2010 16:35:59 -0400
In-Reply-To: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fred, I merged those patches as well the rebased dependent patches
I took from your pnfs-block git tree - under pnfs-all-2.6.35-rc2-2010-06-12

Thanks!

Benny

On Jun. 11, 2010, 10:31 +0300, Fred Isaman <iisaman@netapp.com> wrote:
> This is version 2 of a patch series that limits LAYOUTGET invocation
> to the beginning of the IO paths. It is intended for the pnfs_submit branch,
> without reversion in a post_submit branch.
> 
> Patches 1-4 revert direct IO.  Commit is already broken, and this
> series breaks them further.  The problem is that the direct IO
> redefines data->wb_req and data->pages, so that it can only work with
> the pnfs code if we don't look at those fields. The reverted code should
> be saved somewhere.  I tend to agree with Boaz that keeping it in git is preferable, but I can supply a patch which returns the code ifdef'ed out if tht is preferred.
> 
> Patches 5-9 do some code cleanup in preperation for the real work.
> 
> Patches 10-21 implement the change.  NOTE that patch 20 changes the
> calling convention of the layout drivers commit calls.  There is no
> longer a universal lseg for the commit, instead each nfs_page has an
> lseg attached, with NULL meaning to go through the MDS.
> 
> Patches 22-26 rework the filelayout commit function, and then do some
> other code cleanup.
> 
> 
> 
> The basic idea of these patches is as follows:
> 
> We attempt to grab a lseg (possibly invoking LAYOUTGET) early in the
> IO.  If we succeed, we refcount and stash it, using it through the
> rest of the io.  If we fail, we revert to straight nfs, even if the
> area becomes covered by a layout due to other io.
> 
> The tricky, though hopefully anomalous, case is when we start without
> the layout, but have it at this particular stage of the IO.  We ignore
> this for the moment at write_pages, which will cause block and object
> to issue CB_LAYOUTRECALL.  At commit, it is tricky to handle, but
> since block doesn't use commit, and file needs to handle complicated
> splitting anyway, I just push all complicated decisions of splitting
> commit between nfs (for IO started without layout) and pnfs to the
> driver.
> 
> Fred
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
