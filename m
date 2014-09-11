Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52881 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbaIKP3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:29:08 -0400
Date: Thu, 11 Sep 2014 17:29:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] pnfs: remove GETDEVICELIST implementation
Message-ID: <20140911152906.GF6690@lst.de>
References: <1410395791-2385-1-git-send-email-hch@lst.de> <1410395791-2385-5-git-send-email-hch@lst.de> <CAKVebiWqxFF8GO4kkVr7AtO0gTC+o1Zb0QpfU4wC_oSAoeG-AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiWqxFF8GO4kkVr7AtO0gTC+o1Zb0QpfU4wC_oSAoeG-AQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 10:51:17PM +0800, Peng Tao wrote:
> I am missing patch 3/4, which I assume would fill in the gap where
> GETDEVICEINFO is sent for block layout. Can you please resent that?

That was part of a different series that Trond merged:

pnfs: factor GETDEVICEINFO implementations V2

from September, 2nd.

