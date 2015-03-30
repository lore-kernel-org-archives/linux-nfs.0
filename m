Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33676 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596AbbC3RxW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 13:53:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 00/15] NFS/RDMA patches proposed for 4.1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55195B3B.40205@opengridcomputing.com>
Date: Mon, 30 Mar 2015 13:53:02 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9D560F87-71BF-470E-B411-EF68D75070AA@oracle.com>
References: <20150324201849.2311.53599.stgit@manet.1015granger.net> <55195B3B.40205@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 30, 2015, at 10:18 AM, Steve Wise <swise@opengridcomputing.com> wrote:

> Hey Chuck,
> 
> Chelsio's QA regression tested this series on iw_cxgb4.  Tests out good.
> 
> Tests ran: spew, ffsb, xdd, fio, dbench, and cthon with both v3 and v4.

Thanks, Steve. Who should I credit in the Tested-by tag?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



