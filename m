Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64114C433F5
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Oct 2021 05:33:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4BF2E611F2
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Oct 2021 05:33:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229972AbhJTFf6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Oct 2021 01:35:58 -0400
Received: from verein.lst.de ([213.95.11.211]:40673 "EHLO verein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229920AbhJTFf5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Oct 2021 01:35:57 -0400
Received: by verein.lst.de (Postfix, from userid 2407)
        id 607DE68BEB; Wed, 20 Oct 2021 07:33:41 +0200 (CEST)
Date:   Wed, 20 Oct 2021 07:33:41 +0200
From:   Christoph Hellwig <hch@lst.de>
To:     "Martin K. Petersen" <martin.petersen@oracle.com>
Cc:     Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-block@vger.kernel.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: remove QUEUE_FLAG_SCSI_PASSTHROUGH v2
Message-ID: <20211020053341.GA25529@lst.de>
References: <20211019075418.2332481-1-hch@lst.de> <yq15ytsbawr.fsf@ca-mkp.ca.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yq15ytsbawr.fsf@ca-mkp.ca.oracle.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 20, 2021 at 12:05:24AM -0400, Martin K. Petersen wrote:
> 
> Christoph,
> 
> > The changes to support pktcdvd are a bit ugly, but I can't think of
> > anything better (except for removing the driver entirely).  If we'd
> > want to support packet writing today it would probably live entirely
> > inside the sr driver.
> 
> Yeah, I agree.
> 
> Anyway. No major objections from me. Not sure whether it makes most
> sense for this to go through block or scsi?

I'm not sure either, but either tree is fine with me.
