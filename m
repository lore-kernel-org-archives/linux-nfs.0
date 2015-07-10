Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-08.prod.phx3.secureserver.net ([173.201.193.109]:46526
	"EHLO p3plsmtpa08-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932295AbbGJNFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 09:05:46 -0400
Message-ID: <559FC17A.7060502@talpey.com>
Date: Fri, 10 Jul 2015 08:58:34 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Devesh Sharma <devesh.sharma@avagotech.com>,
        Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 09/12] xprtrdma: Prepare rpcrdma_ep_post() for RDMA_NOMSG
 calls
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>	<20150709204305.26247.39173.stgit@manet.1015granger.net> <CANjDDBh38PrxGgWGuKYCYcbjqY9ELrpkGqaRZ_ueKfD7FEQP8g@mail.gmail.com>
In-Reply-To: <CANjDDBh38PrxGgWGuKYCYcbjqY9ELrpkGqaRZ_ueKfD7FEQP8g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/10/2015 7:29 AM, Devesh Sharma wrote:
> we need to honor the max limits of device by checking
> dev_attr.max_sge? a vendor may not support 4 sges.

iWARP requires a minimum of 4 send SGEs (draft-hilland-verbs 8.1.3.2)

    An RI MUST support at least four Scatter/Gather Elements per
    Scatter/Gather List when the Scatter/Gather List refers to the Data
    Source of a Send Operation Type or the Data Sink of a Receive
    Operation. An RI is NOT REQUIRED to support more than one
    Scatter/Gather Element per Scatter/Gather List when the
    Scatter/Gather List refers to the Data Source of an RDMA Write.

I'm not certain if IB and RoCE state a similar minimum requirement,
but it seems a very bad idea to have fewer.

