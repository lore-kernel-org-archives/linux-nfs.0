Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bn1on0059.outbound.protection.outlook.com ([157.56.110.59]:64512
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964918AbbEFH1w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 03:27:52 -0400
Message-ID: <5549BE30.8020505@sandisk.com>
Date: Wed, 6 May 2015 09:09:36 +0200
From: Bart Van Assche <bart.vanassche@sandisk.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>, Tom Talpey <tom@talpey.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
 <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
 <20150505172540.GA19442@infradead.org> <55490886.4070502@talpey.com>
 <20150505191012.GA21164@infradead.org> <55492ED3.7000507@talpey.com>
 <20150505210627.GA5941@infradead.org>
In-Reply-To: <20150505210627.GA5941@infradead.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/05/15 23:06, Christoph Hellwig wrote:
> The contiguous requirements isn't something we can alway guarantee.
> While a lot of I/O will have that form the form where there are holes
> can happen, although it's not common.

Indeed. That is why there is code in the SRP initiator that uses 
multiple FRWR registrations when a discontiguous SG-list is passed to 
that driver by the SCSI mid-layer. Some time ago I had posted a test 
program that makes the SCSI mid-layer submit a discontiguous I/O request 
to a SCSI LLD (see also 
https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg21224.html).

Bart.

