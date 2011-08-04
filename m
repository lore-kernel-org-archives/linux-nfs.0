Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:47359 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756512Ab1HDBQP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 21:16:15 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p741GDZX024726
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 19:16:13 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p741GChN198132
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 19:16:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p741GC4n012338
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 19:16:12 -0600
Received: from malahal ([9.47.25.235])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p741GCjW012330
	for <linux-nfs@vger.kernel.org>; Wed, 3 Aug 2011 19:16:12 -0600
Date: Wed, 3 Aug 2011 18:16:11 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110804011611.GA24568@us.ibm.com>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A778B9B@SACMVEXC2-PRD.hq.netapp.com>
 <20110804082311.21b7e73a@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110804082311.21b7e73a@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NeilBrown [neilb@suse.de] wrote:
> 
> I substantially agree, though I think the implication can be refined a
> little.
> 
> I would say that the implication is that a VFH is only really usable
> when the complete path leading to the file in question is read-only.
> We don't need to assume that other files in other parts of the
> hierarchy which have stable file handles are read-only.
> 
> So if the server presents us with a VFH, it seems reasonable to assume
> that we can use a repeated lookup of the same name to refresh the
> filehandle simply because there is no other credible way to respond to
> a FHEXPIRED.

The spec seems to imply that repeated lookup of the same name to refresh
the file handle is OK as long as the file is OPEN! It doesn't seem to imply
anything for files that are not opened.

"RFC 3530, 4.2.3. Volatile Filehandle" states:

"Servers which provide volatile filehandles that may expire while open
(i.e., if FH4_VOL_MIGRATION or FH4_VOL_RENAME is set or if
FH4_VOLATILE_ANY is set and FH4_NOEXPIRE_WITH_OPEN not set), should deny
a RENAME or REMOVE that would affect an OPEN file of any of the
components leading to the OPEN file.  In addition, the server should
deny all RENAME or REMOVE requests during the grace period upon server
restart."

On the other hand, if FH4_NOEXPIRE_WITH_OPEN is set, then the file can
be allowed to be renamed or removed by the server.

Thanks, Malahal.
