Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36318 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755074AbbHCTcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 15:32:35 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>, <dledford@redhat.com>
Cc: <infinipath@intel.com>, <sagig@mellanox.com>, <ogerlitz@mellanox.com>,
        <roid@mellanox.com>, <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int> <20150724161848.25617.26092.stgit@build2.ogc.int> <55B4B190.7070305@dev.mellanox.co.il> <55B5404F.5040404@opengridcomputing.com>
In-Reply-To: <55B5404F.5040404@opengridcomputing.com>
Subject: RE: [PATCH V6 6/9] isert: Rename IO functions to more descriptive names
Date: Mon, 3 Aug 2015 14:32:35 -0500
Message-ID: <000001d0ce23$27048810$750d9830$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> > Steve,
> >
> > I've given this some thought and I think we should avoid splitting
> > logic from PI and iWARP. The reason (other than code duplication) is
> > that currently the iser target support only up to 1MB IOs. I have some
> > code (not done yet) to support larger IOs by using multiple
> > registrations  per IO (with or without PI).
> > With a little tweaking I think we can get iwarp to fit in too...
> >
> > So, do you mind if I take a crack at it?
> 
> Sure, go ahead.  Let me know how I can help.  Certainly I can test it
> for you.  I'm very keen to get this in for 4.3 if possible...
> 

Hey Sagi, how is this coming along?  How can I help?

Steve.

