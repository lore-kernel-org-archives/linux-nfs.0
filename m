Return-Path: <SRS0=fE1b=5E=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 344C5C4332B
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Mar 2020 22:13:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0304B2076E
	for <linux-nfs@archiver.kernel.org>; Thu, 19 Mar 2020 22:13:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="Nw7vpfw+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727466AbgCSWNz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 Mar 2020 18:13:55 -0400
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:6279 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727383AbgCSWNz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2020 18:13:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1584656034; x=1616192034;
  h=date:from:to:cc:message-id:references:mime-version:
   in-reply-to:subject;
  bh=P+GcJ3nQC52H8ooN0sQKgDWS2OzM/zXfR3vd3OfdEQg=;
  b=Nw7vpfw+KQ1azh6mJR7BHiR3zEl399fKbeOc5N0woTLXOPB+OgAuHNDv
   nnjLX2P7H5n6EGlvzm5Yf7daCpRpfiNczQ7+fD4ucXiLapg4jJdR8YYBy
   Zl0JmMoVqiAhQG4VTgWLHsKC9K1iH50RmKsXPolg2yw1YDXUJK2FjmuDq
   A=;
IronPort-SDR: zxFNEpjmlHwdMh5ZO70mHdH2+R3TgDshxijzckG3JQo3Phak4d+9AmUnbZC/TSegnutGjiMwSn
 C9KUewajnSKQ==
X-IronPort-AV: E=Sophos;i="5.70,573,1574121600"; 
   d="scan'208";a="33638905"
Subject: Re: [PATCH 11/14] nfsd: add user xattr RPC XDR encoding/decoding logic
Received: from sea32-co-svc-lb4-vlan3.sea.corp.amazon.com (HELO email-inbound-relay-2b-5bdc5131.us-west-2.amazon.com) ([10.47.23.38])
  by smtp-border-fw-out-33001.sea14.amazon.com with ESMTP; 19 Mar 2020 22:13:52 +0000
Received: from EX13MTAUWB001.ant.amazon.com (pdx4-ws-svc-p6-lb7-vlan3.pdx.amazon.com [10.170.41.166])
        by email-inbound-relay-2b-5bdc5131.us-west-2.amazon.com (Postfix) with ESMTPS id C04EEA25C7;
        Thu, 19 Mar 2020 22:13:51 +0000 (UTC)
Received: from EX13D07UWB003.ant.amazon.com (10.43.161.66) by
 EX13MTAUWB001.ant.amazon.com (10.43.161.249) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 19 Mar 2020 22:13:51 +0000
Received: from EX13MTAUWB001.ant.amazon.com (10.43.161.207) by
 EX13D07UWB003.ant.amazon.com (10.43.161.66) with Microsoft SMTP Server (TLS)
 id 15.0.1497.2; Thu, 19 Mar 2020 22:13:51 +0000
Received: from dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com
 (172.23.141.97) by mail-relay.amazon.com (10.43.161.249) with Microsoft SMTP
 Server id 15.0.1367.3 via Frontend Transport; Thu, 19 Mar 2020 22:13:50 +0000
Received: by dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com (Postfix, from userid 6262777)
        id ADBF9CE71E; Thu, 19 Mar 2020 22:13:50 +0000 (UTC)
Date:   Thu, 19 Mar 2020 22:13:50 +0000
From:   Frank van der Linden <fllinden@amazon.com>
To:     Chuck Lever <chuck.lever@oracle.com>
CC:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <20200319221350.GA18279@dev-dsk-fllinden-2c-c1893d73.us-west-2.amazon.com>
References: <20200311195954.27117-1-fllinden@amazon.com>
 <20200311195954.27117-12-fllinden@amazon.com>
 <17D7709F-2FE0-4B84-A9AF-4D6C2B36A4E7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <17D7709F-2FE0-4B84-A9AF-4D6C2B36A4E7@oracle.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Mar 12, 2020 at 12:24:18PM -0400, Chuck Lever wrote:
> > +static inline u32 nfsd4_getxattr_rsize(struct svc_rqst *rqstp,
> > +                                    struct nfsd4_op *op)
> > +{
> > +     u32 maxcount, rlen;
> > +
> > +     maxcount = svc_max_payload(rqstp);
> > +     rlen = min_t(u32, XATTR_SIZE_MAX, maxcount);
> > +
> > +     return (op_encode_hdr_size + 1 + XDR_QUADLEN(rlen)) * sizeof(__be32);
> 
> These should be added in the same patch that adds OP_GETXATTR and friends.
> 
> Also, Trond recently added xdr_align_size which I prefer over the
> use of XDR_QUADLEN in new code.

Thanks, I've squashed together those patches for this and the other reasons
you pointed out.

As for XDR_QUADLEN: that returns the 32bit-word rounded up lenghth - in words.
xdr_aligned_size returns the 32bit-word rounded up length - in bytes.

So, the result would then look something like:

	return xdr_align_size((op_encode_hdr_size * 4) + 4 + rlen);

Is that what you're suggesting?

- Frank
