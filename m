Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:55225 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751227AbaC1Nib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Mar 2014 09:38:31 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <tom@opengridcomputing.com>
References: <20140325201457.6861.21819.stgit@build.ogc.int> <20140328020834.GD27633@fieldses.org>
In-Reply-To: <20140328020834.GD27633@fieldses.org>
Subject: RE: [PATCH] Fix regression in NFSRDMA server
Date: Fri, 28 Mar 2014 08:38:38 -0500
Message-ID: <000301cf4a8b$0652c130$12f84390$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >
> > The server regression was caused by the addition of rq_next_page
> > (afc59400d6c65bad66d4ad0b2daf879cbff8e23e). There were a few places that
> > were missed with the update of the rq_respages array.
> 
> Apologies.  (But, it could happen again--could we set up some regular
> testing?  It doesn't have to be anything fancy, just cthon over
> rdma--really, just read and write over rdma--would probably catch a
> lot.)
> 

Chelsio is adding NFSRDMA testing into their QA flow over their iWARP devices.



