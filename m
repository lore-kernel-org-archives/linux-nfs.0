Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61CE1C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:49:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0017D2082D
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:49:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0017D2082D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726831AbeKCB5K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 21:57:10 -0400
Received: from fieldses.org ([173.255.197.46]:57674 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726700AbeKCB5K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 21:57:10 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 004322430; Fri,  2 Nov 2018 12:49:24 -0400 (EDT)
Date:   Fri, 2 Nov 2018 12:49:24 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
Message-ID: <20181102164924.GB20367@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-8-olga.kornievskaia@gmail.com>
 <20181102154623.GA20367@fieldses.org>
 <CAN-5tyGkz=hHJzQRwBZQgAuGTWq9KLdDreoBoyvWVYQPRLTM0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGkz=hHJzQRwBZQgAuGTWq9KLdDreoBoyvWVYQPRLTM0w@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 02, 2018 at 12:35:26PM -0400, Olga Kornievskaia wrote:
> On Fri, Nov 2, 2018 at 11:46 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:28:59AM -0400, Olga Kornievskaia wrote:
> > > @@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
> > >       p = xdr_reserve_space(&resp->xdr, 4 + 4);
> > >       *p++ = xdr_one; /* cr_consecutive */
> > >       *p++ = cpu_to_be32(copy->cp_synchronous);
> > > +
> > > +     /* allocated in nfsd4_decode_copy */
> > > +     kfree(copy->cp_src);
> >
> > This can result in a leak--for example, if we decode the compound
> > succesfully, but processing fails before we could to this op, then we'll
> > never call this encoder, so we'll allocate without freeing.
> >
> > I think simplest would be to replace this:
> >
> > > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > > index feeb6d4..b4d1140 100644
> > > --- a/fs/nfsd/xdr4.h
> > > +++ b/fs/nfsd/xdr4.h
> > > @@ -521,6 +521,7 @@ struct nfsd4_copy {
> > >       u64             cp_src_pos;
> > >       u64             cp_dst_pos;
> > >       u64             cp_count;
> > > +     struct nl4_server *cp_src;
> >
> > by just a
> >
> >         struct nl4_server cp_src;
> >
> > since it sounds like you really only need one of them, not a whole array
> > (at least for now).
> 
> So this is problematic as the presence of this memory is what is used
> to distinguish "inter" from "intra".

It would be easy enough to add a new bit for that.

> Can things really fail between the xdr and calling of the operation?

Yes.  Consider a PUTFH+SAVEFH+COPY compound.  We decode the whole thing
before starting any processing.  Then we call nfsd4_putfh() and
fh_verify fails (maybe the filehandle is stale or something).  Then
neither nfsd4_copy() nor nfsd4_encode_copy() will be called.

If you absolutely have to do this, you can look at SAVEMEM.

--b.

> What gets freed in the encoder is the "copy" of the what was decoded
> in the decoder. But really freeing in the encoder is the wrong place.
> Encoder doesn't need to free. I already free the "copy" of the
> copy->cp_src in the cleanup_async_copy(). However, what is missing is
> freeing the original copy->cp_src which needs to be freed in the
> dup_copy_fields().
> 
> To clarify:
> copy->cp_src gets allocated in the decoder
> during the process of the copy:
> 1. it gets copied to the kthread and the original copy->cp_src needs
> to be freed. Or during any error it will be freed.
> 2. cleanup_async_copy frees the copy of the copy->cp_src.
> (need to remove the kfree from the encoder).
> 
> >
> > --b.
> >
> > >
> > >       /* both */
> > >       bool            cp_synchronous;
> > > --
> > > 1.8.3.1
