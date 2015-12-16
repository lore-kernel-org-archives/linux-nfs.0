Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44665 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544AbbLPPOD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:14:03 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v3 04/11] xprtrdma: Move struct ib_send_wr off the stack
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151216151115.GA16905@infradead.org>
Date: Wed, 16 Dec 2015 10:13:31 -0500
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>, anna.schumaker@netapp.com,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D5B6F9FD-FF8F-4F37-A3E5-B287B91B1EA4@oracle.com>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net> <20151214211811.16295.47695.stgit@manet.1015granger.net> <56716E6C.4020604@dev.mellanox.co.il> <F2E992ED-2698-43DE-B7C5-4F02DA75AE42@oracle.com> <20151216151115.GA16905@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 16, 2015, at 10:11 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Wed, Dec 16, 2015 at 10:06:33AM -0500, Chuck Lever wrote:
>>> Would it make sense to unionize these as they are guaranteed not to
>>> execute together? Some people don't like this sort of savings.
>> 
>> I dislike unions because they make the code that uses
>> them less readable. I can define macros to help that,
>> but sigh! OK.
> 
> Shouldn't be an issue with transparent unions these days:
> 
> 	union {
> 		struct ib_reg_wr                fr_regwr;
> 		struct ib_send_wr               fr_invwr;
> 	};

Right, but isn't that a gcc-ism that Al hates? If
everyone is OK with that construction, I will use it.

--
Chuck Lever




