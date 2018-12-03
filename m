Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2730C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:41:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 75C8820850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:41:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75C8820850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725989AbeLCXlo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 18:41:44 -0500
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:8405 "EHLO
        ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725915AbeLCXlo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 18:41:44 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 04 Dec 2018 10:10:29 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTxpE-0004Sc-Gf; Tue, 04 Dec 2018 10:40:28 +1100
Date:   Tue, 4 Dec 2018 10:40:28 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Anna Schumaker <schumaker.anna@gmail.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 09/11] vfs: push copy_file_ranges -EXDEV checks down
Message-ID: <20181203234028.GM6311@dastard>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-10-david@fromorbit.com>
 <679f1cda1b43fc4cfcd6cdf6dbac223b42db24c2.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <679f1cda1b43fc4cfcd6cdf6dbac223b42db24c2.camel@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 01:53:35PM -0500, Anna Schumaker wrote:
> On Mon, 2018-12-03 at 19:34 +1100, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > We want to enable cross-filesystem copy_file_range functionality
> > where possible, so push the "same superblock only" checks down to
> > the individual filesystem callouts so they can make their own
> > decisions about cross-superblock copy offload.
....
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index d7766a6eb0f4..4783c0c1c49e 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -133,16 +133,20 @@ static ssize_t nfs4_copy_file_range(struct file
> > *file_in, loff_t pos_in,
> >  				    struct file *file_out, loff_t pos_out,
> >  				    size_t count, unsigned int flags)
> >  {
> > -	ssize_t ret;
> > +	ssize_t ret = -EXDEV;
> >  
> >  	if (file_inode(file_in) == file_inode(file_out))
> >  		return -EINVAL;
> > -retry:
> > -	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
> > -	if (ret == -EAGAIN)
> > -		goto retry;
> >  
> > -	if (ret == -EOPNOTSUPP)
> > +	/* only offload copy if superblock is the same */
> > +	if (file_inode(file_in)->i_sb == file_inode(file_out)->i_sb) {
> > +		do {
> > +			ret = nfs42_proc_copy(file_in, pos_in, file_out,
> > +					pos_out, count);
> > +		} while (ret == -EAGAIN);
> 
> I'm not convinced we can actually return -EAGAIN from nfs42_proc_copy().  The
> nfs_get_lock_context() function doesn't return it, and if _nfs42_proc_copy()
> returns -EAGAIN it's immediately retried by nfs42_proc_copy() instead of
> returning.

Not really my concern, nor something that should be fixed in this
patchset. i.e. the function does the same thing before and after
this patch, so whether EAGAIN can occurr or not is irrelevant to
this patchset....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
