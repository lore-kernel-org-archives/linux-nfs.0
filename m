Return-Path: <SRS0=jEWo=55=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2357EC2BA2B
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Apr 2020 19:29:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0AF2220735
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Apr 2020 19:29:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728725AbgDMT3J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 13 Apr 2020 15:29:09 -0400
Received: from fieldses.org ([173.255.197.46]:46268 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728291AbgDMT3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Apr 2020 15:29:08 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 5B3331C22; Mon, 13 Apr 2020 15:29:07 -0400 (EDT)
Date:   Mon, 13 Apr 2020 15:29:07 -0400
To:     Jason Gunthorpe <jgg@ziepe.ca>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Leon Romanovsky <leon@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 3/3] svcrdma: Fix leak of svc_rdma_recv_ctxt objects
Message-ID: <20200413192907.GA23596@fieldses.org>
References: <20200407190938.24045.64947.stgit@klimt.1015granger.net>
 <20200407191106.24045.88035.stgit@klimt.1015granger.net>
 <20200408060242.GB3310@unreal>
 <D3CFDCAA-589C-4B3F-B769-099BF775D098@oracle.com>
 <20200409174750.GK11886@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200409174750.GK11886@ziepe.ca>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 09, 2020 at 02:47:50PM -0300, Jason Gunthorpe wrote:
> On Thu, Apr 09, 2020 at 10:33:32AM -0400, Chuck Lever wrote:
> > The commit ID is what automation should key off of. The short
> > description is only for human consumption. 
> 
> Right, so if the actual commit message isn't included so humans can
> read it then what was the point of including anything?

Personally as a human reading commits in a terminal window I prefer the
abbreviated form.

I haven't been doing the redundant parentheses and quotes either.  Was
that dreamt up by an Arlo Guthrie fan?  ("KID, HAVE YOU REHABILITATED
YOURSELF?")

--b.
