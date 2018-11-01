Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC49BC6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 21:24:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B994B204FD
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 21:24:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B994B204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727312AbeKBG3W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 02:29:22 -0400
Received: from fieldses.org ([173.255.197.46]:56638 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726969AbeKBG3W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 02:29:22 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 842D9242F; Thu,  1 Nov 2018 17:24:41 -0400 (EDT)
Date:   Thu, 1 Nov 2018 17:24:41 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 05/13] NFS skip recovery of copy open on dest server
Message-ID: <20181101212441.GE12930@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-6-olga.kornievskaia@gmail.com>
 <20181101201955.GB12930@fieldses.org>
 <CAN-5tyF08cLZAtPivj7t_f94HgY7mC3zBh=vp0E8Ez-GQhL7RA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyF08cLZAtPivj7t_f94HgY7mC3zBh=vp0E8Ez-GQhL7RA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 04:38:43PM -0400, Olga Kornievskaia wrote:
> On Thu, Nov 1, 2018 at 4:20 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:28:57AM -0400, Olga Kornievskaia wrote:
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > Mark the open created for the source file on the destination
> > > server. Then if this open is going thru a recovery, then fail
> > > the recovery as we don't need to be recoving a "fake" open.
> > > We need to fail the ongoing READs and vfs_copy_file_range().
> >
> > Nothing to do with this patch, really, but:
> 
> And because it not related to this patch, then I'm confused.
> 
> > I'm not always a stickler about the 80-character-column rule, but, man,
> > nfs4_reclaim_open_state is deeply nested, could that be broken up a
> > little?
> 
> really? it's nested? Anna reworked the reclaim state code and nesting
> has gone done considerably. It's only 2 tabs in?
> 
> >  Also I notice there's a printk("AGLO: ...") in there that you
> > probably didn't mean to leave upstream?
> 
> I don't believe I've ever had a printk() in the code. I did have a
> leftover dprintk() and that has since been removed.

Oh, I see, this was all fixed recently upstream by Anna's cb7a8384dc02
"NFS: Split out the body of nfs4_reclaim_open_state()", ignore me.

--b.
