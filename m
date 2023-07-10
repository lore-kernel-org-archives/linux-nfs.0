Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F230EB64D9
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Jul 2023 15:18:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232049AbjGJPSl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Jul 2023 11:18:41 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40604 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229517AbjGJPSk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jul 2023 11:18:40 -0400
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BF85EA7;
        Mon, 10 Jul 2023 08:18:38 -0700 (PDT)
Received: by verein.lst.de (Postfix, from userid 2407)
        id 64D4D6732D; Mon, 10 Jul 2023 17:18:35 +0200 (CEST)
Date:   Mon, 10 Jul 2023 17:18:35 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <cel@kernel.org>
Subject: Re: NFS workload leaves nfsd threads in D state
Message-ID: <20230710151835.GA31726@lst.de>
References: <7A57C7AE-A51A-4254-888B-FE15CA21F9E9@oracle.com> <20230710075634.GA30120@lst.de> <3F16A14B-F854-41CC-A3CA-87C7946FC277@oracle.com> <F610D6B3-876F-4E5D-A3C4-A30F1B81D9B5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F610D6B3-876F-4E5D-A3C4-A30F1B81D9B5@oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Jul 10, 2023 at 03:10:41PM +0000, Chuck Lever III wrote:
> > I have a way to test it on an xfs export backed by a pair of AIC
> > NVMe devices. Stand by.
> 
> The issue is not reproducible with PCIe NVMe devices.

Thanks.  ATA is special because it can't queued flush commands unlike
all other problems.  I'll see if I can get an ATA test setup and will
look into it ASAP.
