Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 453E9C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:12:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D93A62082E
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:12:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D93A62082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727710AbeKBFRY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:17:24 -0400
Received: from fieldses.org ([173.255.197.46]:56496 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727704AbeKBFRY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 01:17:24 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 183F625F5; Thu,  1 Nov 2018 16:12:57 -0400 (EDT)
Date:   Thu, 1 Nov 2018 16:12:57 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 04/13] NFS inter ssc open
Message-ID: <20181101201257.GA12930@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-5-olga.kornievskaia@gmail.com>
 <20181031184042.GD3377@fieldses.org>
 <CAN-5tyGuVF30ynxYj_EaWDjJJyJTXLXWb=O516XJsThk9AsUvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGuVF30ynxYj_EaWDjJJyJTXLXWb=O516XJsThk9AsUvQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 31, 2018 at 02:54:51PM -0400, Olga Kornievskaia wrote:
> On Wed, Oct 31, 2018 at 2:40 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > Just to pick one thing that I don't understand yet:
> >
> > On Fri, Oct 19, 2018 at 11:28:56AM -0400, Olga Kornievskaia wrote:
> > > +EXPORT_SYMBOL_GPL(nfs42_ssc_open);
> > > +void nfs42_ssc_close(struct file *filep)
> > > +{
> > > +     struct nfs_open_context *ctx = nfs_file_open_context(filep);
> > > +
> > > +     ctx->state->flags = 0;
> >
> > Why is this needed?
> 
> This is needed so that CLOSE isn't going on the wire but closed internally.
> 
> > Also, given the name and the pairing with nfs42_ssc_open(), would it be
> > more logical for it to do the fput() as well?
> 
> I'd like to keep that fput() in the nfsd to make it consistent with
> the "intra". There are fput()s for intra but intra doesn't call into
> nfs42_ssc_close().

OK, I think.

I'll need an ACK from Trond and/or Anna on this one in any case.

--b.
