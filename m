Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9E21ECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 18:46:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 61E15208E3
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 18:46:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61E15208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726996AbeKIEWu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 23:22:50 -0500
Received: from fieldses.org ([173.255.197.46]:38834 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726860AbeKIEWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Nov 2018 23:22:50 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 2F1E62014; Thu,  8 Nov 2018 13:46:03 -0500 (EST)
Date:   Thu, 8 Nov 2018 13:46:03 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/13] NFSD add COPY_NOTIFY operation
Message-ID: <20181108184603.GA6090@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-10-olga.kornievskaia@gmail.com>
 <20181105175006.GA9111@fieldses.org>
 <CAN-5tyELmi6Obv-Ak2gikZ8sBfZ2AamaH6YdmjfGV22j7Zyrkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyELmi6Obv-Ak2gikZ8sBfZ2AamaH6YdmjfGV22j7Zyrkw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 08, 2018 at 01:29:26PM -0500, Olga Kornievskaia wrote:
> On Mon, Nov 5, 2018 at 12:50 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:29:01AM -0400, Olga Kornievskaia wrote:
> > > @@ -2720,6 +2775,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> > >               .op_name = "OP_OFFLOAD_CANCEL",
> > >               .op_rsize_bop = nfsd4_only_status_rsize,
> > >       },
> > > +     [OP_COPY_NOTIFY] = {
> > > +             .op_func = nfsd4_copy_notify,
> > > +             .op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
> >
> > CACHEME is actually only used for 4.0, let's drop it from
> > nfs4.1/4.2-only operations.
> 
> Ah well COPY And CLONE had the CACHEME and thus I had it. I'll remove
> it. We provably need to remove it from 4.2 ops: COPY, CLONE, ALLOCATE,
> DEALLOCATE...

OK, that could be a separate patch.

--b.
