Return-Path: <SRS0=C+as=3Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70A7CC35247
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Feb 2020 19:17:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4A3172087E
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Feb 2020 19:17:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727358AbgBDTR0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Feb 2020 14:17:26 -0500
Received: from fieldses.org ([173.255.197.46]:37788 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727442AbgBDTR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Feb 2020 14:17:26 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id F1EF9ABE; Tue,  4 Feb 2020 14:17:25 -0500 (EST)
Date:   Tue, 4 Feb 2020 14:17:25 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: Fix NFSv4 READ on RDMA when using readv
Message-ID: <20200204191725.GA10811@fieldses.org>
References: <20200201195914.12238.15729.stgit@bazille.1015granger.net>
 <20200204172154.GB8763@fieldses.org>
 <B95D88FC-C76D-42A2-9366-CA226757BA42@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B95D88FC-C76D-42A2-9366-CA226757BA42@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 04, 2020 at 01:43:56PM -0500, Chuck Lever wrote:
> 
> 
> > On Feb 4, 2020, at 12:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Sat, Feb 01, 2020 at 03:05:19PM -0500, Chuck Lever wrote:
> >> Changes since RFC2:
> >> - Take Trond's suggestion to use xdr->buf->len
> >> - Squash fix down to a single patch
> > 
> > I liked them better split out.
> > 
> > This seems fine to me, though.
> > 
> > Could you ping me again in another week, after the merge window?
> > 
> >> @@ -3521,17 +3521,14 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
> >> 	u32 zzz = 0;
> >> 	int pad;
> >> 
> >> +	/* Ensure xdr_reserve_space skips past xdr->buf->head */
> > 
> > Could the comment explain why we're doing this?  (Maybe take some
> > language from the changelog.)
> 
> The new comment will also explain why the patches are combined.
> I'll send a v4 after the merge window closes.

Hah, OK, thanks!

--b.
