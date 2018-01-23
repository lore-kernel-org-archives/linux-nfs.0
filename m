Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:37234 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751324AbeAWQia (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jan 2018 11:38:30 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH v3 1/2] rdma/ib: Add trace point macros to display
 human-readable values
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180122174709.GE14372@ziepe.ca>
Date: Tue, 23 Jan 2018 08:38:27 -0800
Cc: dledford@redhat.com, Anna Schumaker <anna.schumaker@netapp.com>,
        leon@kernel.org, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A6F9729C-9922-4C9D-9264-F053DB76B622@oracle.com>
References: <20180120161440.6488.4311.stgit@manet.1015granger.net>
 <20180120161625.6488.7416.stgit@manet.1015granger.net>
 <20180122174709.GE14372@ziepe.ca>
To: Jason Gunthorpe <jgg@ziepe.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 22, 2018, at 9:47 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>=20
> On Sat, Jan 20, 2018 at 11:16:25AM -0500, Chuck Lever wrote:
>> These can be shared with all kernel ULPs, and more can easily be
>> added as needed.
>>=20
>> Note: checkpatch.pl has some heartburn with the TRACE_DEFINE_ENUM
>> macros and the LIST macros. These follow the same style as other
>> header files under include/tracing/events , thus should be
>> considered acceptable exceptions.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> include/trace/events/rdma.h |  129 =
+++++++++++++++++++++++++++++++++++++++++++
>> 1 file changed, 129 insertions(+)
>> create mode 100644 include/trace/events/rdma.h
>=20
> Not knowing a lout about trace points, this does seem OK to me:
>=20
> Acked-by: Jason Gunthorpe <jgg@mellanox.com>
>=20
> To flow through Anna's tree

Thanks, Jason.

--
Chuck Lever



