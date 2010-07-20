From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/5] pnfs-submit fix kfree under spin lock
Date: Tue, 20 Jul 2010 13:30:35 -0400
Message-ID: <AANLkTikzt-A69kM863U=YuGZ1-HGWr51KsJEts3uKFx6@mail.gmail.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52496 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab0GTRag convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 13:30:36 -0400
Received: by iwn7 with SMTP id 7so5869908iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jul 2010 10:30:35 -0700 (PDT)
In-Reply-To: <1279645283-9862-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond and Fred informed me that kfree under a spin lock is actually
OK. So, maybe these patches aren't needed.

On the other hand, with these patches we don't hold the spin lock over
function calls which to my mind is easier to read. Also, the
free_layout/free_lseg layoutdriver calls may do more than call kfree.

At least, we should document what we expect from the
free_layout/free_lseg - e.g. no side affects that conflict with being
called under a spinlock..

-->Andy

On Tue, Jul 20, 2010 at 1:01 PM,  <andros@netapp.com> wrote:
>
> Fix kfree under spin lock
>
> Both put_lseg and put_layout are called under the inode i_lock where =
the
> last reference will end up freeing structures.
>
> I know there has been a lot of churn in this code, but free'ing under=
 the
> spin lock is a no-no.
> In this patch I refactor the layout allocation, combining it with the
> layout segment lookup code. The new function, pnfs_get_layout_segment=
 takes
> inode spin lock, and looks to see if the requested range is serviced =
by an
> existing layout segment. If the layout has not been allocated, alloca=
te it.
> If a layout segement is found, reference it and give up the lock. If =
no
> layout segment is found, reference the layout for the layoutget call =
and
> give up the lock.
>
> 0001-SQUASHME-pnfs-submit-alloc-layout-don-t-call-put_lay.patch
> 0002-SQUASHME-pnfs-submit-use-atomic_dec_and_lock-for-lay.patch
>
> Fix the put_lseg under spin lock.
> 0003-SQUASHME-pnfs-submit-don-t-call-put_lseg-under-spin-.patch
>
> Cleanup.
> 0004-SQUASHME-pnfs-submit-pnfs_release_layout-just-use-in.patch
> 0005-SQUASHME-pnfs-submit-fix-has_layout-compile-error.patch
>
> Tests:
> CONFIG_NFS_V4_1 set:
> Connectathon tests pass against GFS2 and pyNFS file layout servers.
>
> CONFIG_NFS_V4_1 not set:
> Connectathon tests pass.
>
> -->Andy
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
