Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45962 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068Ab1HDP4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 11:56:19 -0400
Date: Thu, 4 Aug 2011 11:56:15 -0400
To: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com
Subject: Re: State of NFSv4 VolatileFilehandles
Message-ID: <20110804155615.GB12445@fieldses.org>
References: <4E37E66D.90102@linux.vnet.ibm.com>
 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
 <4E38F894.4070003@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E38F894.4070003@linux.vnet.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 03, 2011 at 12:28:20AM -0700, Venkateswararao Jujjuri wrote:
> On 08/02/2011 07:53 AM, Chuck Lever wrote:
> >We don't have firm plans for a server migration implementation on Linux at this time, but Bruce can maybe say more about that.
> Sure; would wait for Bruce's views on this. We are getting
> requirements for both client and server support.

We've been looking at migration and failover, backed by a cluster
filesystem, using floating IP's as a way to get most of the benefits
without quite as much fiddling with protocol issues and without
requiring the absolute latest clients.

We'd likely look into NFSv4 protocol-based migration after that.  Is
there some reason you require that in particular?  Is it only because
you want to be able to migrate using rsync and count on the client
recovering volatile filehandles?

--b.
