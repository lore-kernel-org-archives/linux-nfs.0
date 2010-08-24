From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: The pnfs-submit tree with renaming done.
Date: Tue, 24 Aug 2010 12:34:16 -0400
Message-ID: <AANLkTikXA7qSASZcCFQ9aL=H59h3HFc9jGecYS8w2WS5@mail.gmail.com>
References: <AANLkTinPR+vKXFvptrh7vKHgf1fSqQ2Fq7YjYNDw0_rp@mail.gmail.com>
	<4C72171F.8010802@panasas.com>
	<4C72318C.4080402@panasas.com>
	<AANLkTimw2oFRvLbrHAgTY7zoWQG15qhyz33k9+t69Xv=@mail.gmail.com>
	<4C73DA58.9090408@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:49469 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755133Ab0HXQeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:34:17 -0400
Received: by gwj17 with SMTP id 17so2591328gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:34:17 -0700 (PDT)
In-Reply-To: <4C73DA58.9090408@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Benny - looks great :)

-->Andy

On Tue, Aug 24, 2010 at 10:42 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> Hi Andy,
>
> Thanks for the tarball you sent with the pnfs-submit patchset
> with renamed types.
>
> I merged into the tree and applied the renames onto the post submit patches
> and obj/block layout drivers.
>
> I added some renames for the callback code to match
> the existing naming convention and did a bit of cleanup of the patchset
> and the post submit series, including splicing the tail of the submit patchset
> into the post submit branch head.
>
> I revived the "pnfsd, pnfs: protocol level pnfs constants" preliminary patch
> as it contains no-brainer nfsv4.1 definitions that Trond already agreed
> can be submitted as a whole and not per use.
> This simplifies rebasing of the pnfs-submit branch as pnfs-submit-all
> and makes more sense overall IMO.
>
> I also resurrected Bruce's stats code in the "remove this unused code"
> patch, and added a question mark for this patch as I think it requires
> more through review to agree exactly what should go away for good.
> (Some of it is obvious and I should've probably put it aside...)
>
> I released this clean version as pnfs-all-2.6.35-2010-08-24
> ad I'm working on rebasing onto 2.6.36-rc1.
>
> At this point, I'd like to close the 2.6.35 stream for new features
> and release only fixes to it from now on.
>
> Benny
>
