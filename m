Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-by2on0079.outbound.protection.outlook.com ([207.46.100.79]:2561
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751713AbbEFHdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 03:33:54 -0400
Message-ID: <5549BC33.30905@sandisk.com>
Date: Wed, 6 May 2015 09:01:07 +0200
From: Bart Van Assche <bart.vanassche@sandisk.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>
CC: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
 <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
 <20150505172540.GA19442@infradead.org> <55490886.4070502@talpey.com>
 <20150505191012.GA21164@infradead.org> <55492ED3.7000507@talpey.com>
 <20150505210627.GA5941@infradead.org> <554936E5.80607@talpey.com>
 <20150505223855.GA7696@obsidianresearch.com>
In-Reply-To: <20150505223855.GA7696@obsidianresearch.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/06/15 00:38, Jason Gunthorpe wrote:
> Heck, on modern systems 100% of these requirements can be solved just
> by using the IOMMU. No need for the HCA at all. (HCA may be more
> performant, of course)

Hello Jason,

Any performance tests I have run so far with the IOMMU enabled show much 
worse results than the same test with the IOMMU disabled. The perf tool 
learned me that this performance difference is due to lock contention 
caused by the IOMMU kernel code. I have not yet tried to verify whether 
this is an implementation issue or something fundamental.

This is why I'm not enthusiast about any approach that relies on the 
IOMMU being enabled.

Bart.

