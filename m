Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98DA5ECDE43
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 13:01:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 599FA20869
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 13:01:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Otcin1Gx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 599FA20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727640AbeJUVPu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 17:15:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:56444 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727333AbeJUVPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 21 Oct 2018 17:15:50 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9438E2083E;
        Sun, 21 Oct 2018 13:01:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540126894;
        bh=ndZM/fQMFD9EpTSRyWNhshG29/mbdC68yHkBHrlaXFc=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=Otcin1Gx1eViKx3115Nw9ekMw8FBdpZtc/ykN1eoKf3lnOLIdT33xXEhuGbeZ7vYT
         8s3Aq+3nRVbczUD2+RoBt89eo/QOeSefvkQpH4kmdxFi3XZlDaH7t9ChybNOFaKHFC
         MYf5InzaIng9MJVjQOPqggu4PSuX/km4oCBE2I5I=
Message-ID: <ebb0346420183190d565a9c5bb34c2accc500133.camel@kernel.org>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
From:   Jeff Layton <jlayton@kernel.org>
To:     Matthew Wilcox <willy@infradead.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>
Date:   Sun, 21 Oct 2018 09:01:31 -0400
In-Reply-To: <20181019190630.GC28891@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
         <20181019153018.32507-2-olga.kornievskaia@gmail.com>
         <20181019175822.GB28891@bombadil.infradead.org>
         <CAN-5tyHvJQc+mPSvgX09F71otoZEoxRXdKLB=F=bGTzmEnt_eA@mail.gmail.com>
         <20181019190630.GC28891@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-19 at 12:06 -0700, Matthew Wilcox wrote:
> On Fri, Oct 19, 2018 at 02:47:42PM -0400, Olga Kornievskaia wrote:
> > On Fri, Oct 19, 2018 at 1:58 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > 
> > > On Fri, Oct 19, 2018 at 11:30:18AM -0400, Olga Kornievskaia wrote:
> > > > +++ b/Documentation/filesystems/vfs.txt
> > > > @@ -958,7 +958,9 @@ otherwise noted.
> > > > 
> > > >    fallocate: called by the VFS to preallocate blocks or punch a hole.
> > > > 
> > > > -  copy_file_range: called by the copy_file_range(2) system call.
> > > > +  copy_file_range: called by copy_file_range(2) system call. This method
> > > > +                works on two file descriptors that might reside on
> > > > +                different superblocks of the same type of file system.
> > > 
> > > I don't think this text is explicit enough about what has changed,
> > 
> > Can you suggest a different wording that would be stronger? I can't
> > say any more clear that copy is allowed between different superblock
> > which wasn't the case before.
> 
> I would leave this file alone.
> 
> > > and I
> > > think this is the wrong place for it.  I think there should be a paragraph
> > > in Documentation/filesystems/porting and it should follow the current style
> > > in there.
> > 
> > I have looked at the "porting" file and it's cryptic. I don't
> > understand what [mandatory] [recommended] stanzas are. There is
> > currently no copy_file_range. Is this just a "changelog" and you are
> > looking for something like
> > [mandatory]
> > copy_file_range() now allows copying between different superblocks.
> > 
> > I can add this wording to the "porting" file.
> 
> The porting file is written from the point of view of someone who's trying
> to port an old filesystem to current Linux.
> 
> Maybe something like
> 
> [mandatory]
> 	->copy_file_range() may now be passed files which belong to two
> 	different filesystems.  The destination's copy_file_range() is the
> 	function which is called.  If it cannot copy ranges from the source,
> 	it should return -EXDEV.
> 
> > > > -     if (file_out->f_op->copy_file_range) {
> > > > +     if (file_out->f_op->copy_file_range &&
> > > > +                     (file_in->f_op->copy_file_range ==
> > > > +                             file_out->f_op->copy_file_range)) {
> > > 
> > > Can we avoid this extra test here?  I know the various stamdards groups
> > > including T10 and the IETF have been trying to define a universal
> > > identifier for the same blob of storage, no matter how it's accessed;
> > > potentially allowing access to the same storage across iSCSI, CIFS
> > > and NFS.  If we ever get to a point where we support that (and I am
> > > dubious), we'd want to remove this test again, and have to revalidate
> > > all the filesystems.
> > 
> > Well from previous submissions I was explicitly asked to add this check.
> 
> I'm not sure that's exactly what Jeff was asking for.  Or maybe it was
> and my argument above will change his mind.  Jeff, what do you think?
> 
> If we do do this, cifs will need a modification as part of this patch to
> reject non-CIFS files as it currently assumes that src_file->private_data
> is a pointer to a struct cifsFileInfo.

My suggestion to Olga was more of a "if you feel you have to have a
check like this at the vfs layer...", but I think you and Al have
convinced me that comparing operations like this is not a good idea.

I still think that this check belongs down inside the fs copy_file_range
operation itself. That allows the the freedom to implement xdev copies
on a per-fs basis later without needing to alter vfs-level code.
-- 
Jeff Layton <jlayton@kernel.org>

