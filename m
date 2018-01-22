Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:45338 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbeAVRrO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jan 2018 12:47:14 -0500
Received: by mail-wm0-f65.google.com with SMTP id i186so17890547wmi.4
        for <linux-nfs@vger.kernel.org>; Mon, 22 Jan 2018 09:47:13 -0800 (PST)
Date: Mon, 22 Jan 2018 10:47:09 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: dledford@redhat.com, anna.schumaker@netapp.com, leon@kernel.org,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/2] rdma/ib: Add trace point macros to display
 human-readable values
Message-ID: <20180122174709.GE14372@ziepe.ca>
References: <20180120161440.6488.4311.stgit@manet.1015granger.net>
 <20180120161625.6488.7416.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180120161625.6488.7416.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 20, 2018 at 11:16:25AM -0500, Chuck Lever wrote:
> These can be shared with all kernel ULPs, and more can easily be
> added as needed.
> 
> Note: checkpatch.pl has some heartburn with the TRACE_DEFINE_ENUM
> macros and the LIST macros. These follow the same style as other
> header files under include/tracing/events , thus should be
> considered acceptable exceptions.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>  include/trace/events/rdma.h |  129 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 129 insertions(+)
>  create mode 100644 include/trace/events/rdma.h

Not knowing a lout about trace points, this does seem OK to me:

Acked-by: Jason Gunthorpe <jgg@mellanox.com>

To flow through Anna's tree

Jason
