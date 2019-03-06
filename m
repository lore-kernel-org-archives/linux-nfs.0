Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D4A4C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 16:09:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 189A420675
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 16:09:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728986AbfCFQJf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 11:09:35 -0500
Received: from fieldses.org ([173.255.197.46]:41854 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728638AbfCFQJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 11:09:35 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id CE43537E; Wed,  6 Mar 2019 11:09:34 -0500 (EST)
Date:   Wed, 6 Mar 2019 11:09:34 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "aglo@umich.edu" <aglo@umich.edu>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "joseph.qi@linux.alibaba.com" <joseph.qi@linux.alibaba.com>
Subject: Re: [bug report] task hang while testing xfstests generic/323
Message-ID: <20190306160934.GB3066@fieldses.org>
References: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
 <CAN-5tyG9sUw2Oi+hbaW+KJDhvk8KT3Lb-cgU6azxq1yN+Tr=KQ@mail.gmail.com>
 <3b6597b0-41b4-255a-5ebb-cf34ad95315c@linux.alibaba.com>
 <57796366-0f08-2cfb-6f85-27d5485c07af@linux.alibaba.com>
 <ce839197cb70f3bc75413ed2e54f8baafafc01dd.camel@hammerspace.com>
 <365504c3-d785-7e4b-1dd2-c75f30c85c65@linux.alibaba.com>
 <740c1ad6c5b2afad196af34f48dda7097b5102b7.camel@hammerspace.com>
 <1417d6c8-3602-d895-a036-44031a7c1e98@linux.alibaba.com>
 <b729878b38f32053890a592a91f0645f15caa96f.camel@hammerspace.com>
 <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46f5c870-f4fd-b29a-f5eb-eab39c4c1e89@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 05:59:39PM +0800, Jiufei Xue wrote:
> Hi Trond,
> 
> > 
> > No, that's quite weird... Were you able to catch this behaviour on
> > wireshark? It would be interesting to see if the server is actually
> > sending 2 SEQUENCE ops or if that is a corruption that occurs on the
> > client.
> > 
> 
> Many packages are dropped by kernel when I use tcpdump, so I am not sure
> whether the server is sending 2 SEQUENCE.

For what it's worth, tcpdump with -s200 or so should be enough to get
this.  Or maybe capturing from a different machine could help?

> However, according to tracepoint nfsd_compound_status, the server is
> processing SEQUENCE op only once. I think it is more likely blames to
> the client.

If there was a bug in nfsd's xdr decoding, that'd happen after that
tracepoint.  That'd be weird corruption, but perhaps all the
possibilites are weird at this point.

--b.

> Is there any other way to catch the behaviour?
> 
> Thanks,
> Jiufei 
> 
