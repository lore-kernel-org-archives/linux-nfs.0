Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:40134 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbbHEVXY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:23:24 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>, <dledford@redhat.com>
Cc: <infinipath@intel.com>, <sagig@mellanox.com>, <ogerlitz@mellanox.com>,
        <roid@mellanox.com>, <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int> <20150724161848.25617.26092.stgit@build2.ogc.int> <55B4B190.7070305@dev.mellanox.co.il> <55B5404F.5040404@opengridcomputing.com> <000001d0ce23$27048810$750d9830$@opengridcomputing.com> <55C0F5B7.4040100@dev.mellanox.co.il> 
In-Reply-To: 
Subject: RE: [PATCH V6 6/9] isert: Rename IO functions to more descriptive names
Date: Wed, 5 Aug 2015 16:23:27 -0500
Message-ID: <00b001d0cfc4$f83a14c0$e8ae3e40$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> >
> > > Hey Sagi, how is this coming along?  How can I help?
> > >
> >
> > Hi Steve,
> >
> > This is taking longer than I expected, the changes needed seem
> > pretty extensive throughout the IO path. I don't think it will be ready
> > for 4.3
> >
> 
> Perhaps then we should go with my version that adds iwarp-only FRMR IO handlers for 4.3.  Then they can be phased out as the rework
> matures.  Thoughts?
> 

Shall I send out the series again for merging into 4.3?

Thanks,

Steve.

