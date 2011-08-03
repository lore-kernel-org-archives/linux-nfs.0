Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:46397 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab1HCPnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 11:43:06 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p73FU392023693
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 11:30:04 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p73Fh5CD1527826
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 11:43:05 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p73Fh414031641
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 11:43:04 -0400
Received: from malahal ([9.47.25.235])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p73Fh4jd031615
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 11:43:04 -0400
Date: Wed, 3 Aug 2011 08:43:03 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110803154303.GA11165@us.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E38F894.4070003@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Venkateswararao Jujjuri [jvrao@linux.vnet.ibm.com] wrote:
> >I think we are avoiding volatile file handles as long as possible.  We don't have plans to implement them at the moment.
> Hrm. How can we achieve the complete migration support without
> volatile filehandle support?

If you can generate persistent file handles that don't include server
specific information (maybe a bit hard, but not impossible), migration
can be done. Maybe that is what Chuck is talking about.
