Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35864 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751395AbdBXRRc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2017 12:17:32 -0500
Received: by mail-qk0-f180.google.com with SMTP id x71so24004682qkb.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Feb 2017 09:17:31 -0800 (PST)
Message-ID: <1487956644.3314.4.camel@redhat.com>
Subject: Re: [PATCH 1/4] sunrpc: flag transports as using IETF approved
 congestion control protocols
From: Jeff Layton <jlayton@redhat.com>
To: Tom Talpey <tom@talpey.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org
Date: Fri, 24 Feb 2017 12:17:24 -0500
In-Reply-To: <4eb1da3d-2690-7647-2d85-cc574bc1d564@talpey.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
         <20170223170337.10686-2-jlayton@redhat.com>
         <2152dfdf-f847-2511-1600-6499b6ea9708@talpey.com>
         <1487880034.3448.8.camel@redhat.com>
         <65056db6-f30a-c44d-b01c-b549887c4895@talpey.com>
         <20170223201109.GC11882@fieldses.org>
         <20170223202609.GC26301@obsidianresearch.com>
         <18ef37c3-95db-9a2c-dbcb-f579672065d6@talpey.com>
         <20170223205502.GA29673@obsidianresearch.com>
         <4eb1da3d-2690-7647-2d85-cc574bc1d564@talpey.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-02-24 at 10:08 -0500, Tom Talpey wrote:
> On 2/23/2017 3:55 PM, Jason Gunthorpe wrote:
> > On Thu, Feb 23, 2017 at 03:33:53PM -0500, Tom Talpey wrote:
> > 
> > > The key words are "IETF-approved". Mitigation and Interaction are
> > > operational decisions, not protocol design.
> > 
> > We are talking about this bit from RFC 3530 ?
> > 
> >    Where an NFS version 4 implementation supports operation over the IP
> >    network protocol, the supported transports between NFS and IP MUST be
> >    among the IETF-approved congestion control transport protocols, which
> >    include TCP and SCTP.
> > 
> > This gives most of RDMA an out as it is not over the IP protocol. The
> > only obvious troubled one is RoCEv2..
> 
> RFC7530 has updated this text somewhat, but it's similar, yes.
> 
> https://tools.ietf.org/html/rfc7530#section-3.1
> 
> The specification language specifically calls out IP-based transports,
> which is why I mentioned that RoCEv1, being non-IP-based and not even
> truly routable, could obtain a bye. But the NFS layer IMO should really
> not be digging down to this level. I think it would be much better if
> each transport could expose a relevant attribute, which NFS could
> optionally inspect.
> 
> As you mention, RoCEv2 is a bit of a pickle. It's UDP/IP-based, and it
> does have end-to-end congestion control, but technically speaking it
> is not "IETF approved". I'm not sure what call to make there.
> 
> Tom.

I'm perfectly willing to forgo the "IETF approved" verbiage since it's
ambiguous anyway. We can certainly just use more weasel words in the
comments as well.

RFC5661 has a bit more to say on the matter:

   NFSv4.1 works over Remote Direct Memory Access (RDMA) and non-RDMA-
   based transports with the following attributes:
   o  The transport supports reliable delivery of data, which NFSv4.1
      requires but neither NFSv4.1 nor RPC has facilities for ensuring
      [34].

   o  The transport delivers data in the order it was sent.  Ordered
      delivery simplifies detection of transmit errors, and simplifies
      the sending of arbitrary sized requests and responses via the
      record marking protocol [3].

I'd rather rely on those attributes instead of any sort of IETF
approval anyway. Do all RDMA transports (RoCEv2, in particular) have
those characteristics?

If not, then perhaps there is some way to have different RDMA transport
drivers set flags in some structure as to whether they fulfill those
requirements, and then have the xprtrdma driver check for those flags.

In any case, for now I think we should just give all RDMA transports a
pass, and clean that up later. I'm mostly interested in excluding UDP
over IP for now -- being more strict with RDMA can come later.
-- 
Jeff Layton <jlayton@redhat.com>
