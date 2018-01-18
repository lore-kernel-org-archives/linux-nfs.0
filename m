Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:43203 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753958AbeARWev (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jan 2018 17:34:51 -0500
Received: by mail-wm0-f67.google.com with SMTP id g1so235097wmg.2
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jan 2018 14:34:50 -0800 (PST)
Date: Thu, 18 Jan 2018 15:34:46 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/12] rdma/ib: Add trace point macros to display
 human-readable values
Message-ID: <20180118223446.GB17294@ziepe.ca>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
 <20171220213023.29321.97527.stgit@manet.1015granger.net>
 <1245d090-99ee-c517-5f8f-afdb7ffc0456@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1245d090-99ee-c517-5f8f-afdb7ffc0456@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 18, 2018 at 04:49:20PM -0500, Anna Schumaker wrote:
> Hi Folks,
> 
> On 12/20/2017 04:30 PM, Chuck Lever wrote:
> > These can be shared with all kernel ULPs, and more can easily be
> > added as needed.
> > 
> > Note: checkpatch.pl has some heartburn with the TRACE_DEFINE_ENUM
> > macros and the LIST macros. These follow the same style as other
> > header files under include/tracing/events , thus should be
> > considered acceptable exceptions.
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >  include/trace/events/rdma.h |  128 +++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 128 insertions(+)
> >  create mode 100644 include/trace/events/rdma.h
> 
> Just checking that it's okay to send this through the NFS tree,
> since it goes along with the rest of Chuck's patches?

New file, won't create any conflicts, so should be fine.

Is this API or anything that needs a really special look?

> > +++ b/include/trace/events/rdma.h
> > @@ -0,0 +1,128 @@
> > +/*
> > + * Copyright (c) 2017 Oracle.  All rights reserved.
> > + */

This should have a SPDX header though, from what I understand.

Jason
