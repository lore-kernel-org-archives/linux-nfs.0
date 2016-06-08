Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:52780 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932448AbcFHRk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2016 13:40:26 -0400
Date: Wed, 8 Jun 2016 11:40:14 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
Message-ID: <20160608174014.GB30822@obsidianresearch.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
 <20160607194732.18401.71941.stgit@manet.1015granger.net>
 <20160607204941.GA7991@obsidianresearch.com>
 <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com>
 <20160607212831.GA9192@obsidianresearch.com>
 <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
 <20160607220107.GA9982@obsidianresearch.com>
 <c43e37cd-71ea-8629-20f2-bcd674d50b83@talpey.com>
 <8FF9BF11-C5BF-4418-9A84-AAD7A6D6321D@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
In-Reply-To: <8FF9BF11-C5BF-4418-9A84-AAD7A6D6321D@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 08, 2016 at 03:06:56PM +0000, Trond Myklebust wrote:

>    That would be a mount parameter which would only apply to RDMA since
>    everything else uses dynamic slot allocation these days. Iâd prefer to
>    avoid that.

The only reason RDMA cannot allocate MRs on the fly is
performance.. Maybe a dynamic scheme is the right answer..

Jason
