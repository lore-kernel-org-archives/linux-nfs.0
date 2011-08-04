Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30680 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754245Ab1HDQLA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Aug 2011 12:11:00 -0400
Subject: Re: State of NFSv4 VolatileFilehandles
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Thu, 04 Aug 2011 12:10:44 -0400
In-Reply-To: <20110804160344.GC12445@fieldses.org>
References: <4E37E66D.90102@linux.vnet.ibm.com>
	 <45F4FC20-ED44-4430-A5A9-E06459A194F3@oracle.com>
	 <4E38F894.4070003@linux.vnet.ibm.com>
	 <2DD1BC2B-6113-4D00-9DD4-C5D431EA1F8A@oracle.com>
	 <4E3A8225.1020309@linux.vnet.ibm.com> <20110804160344.GC12445@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312474244.5806.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-08-04 at 12:03 -0400, J. Bruce Fields wrote: 
> On Thu, Aug 04, 2011 at 04:27:33AM -0700, Venkateswararao Jujjuri wrote:
> > One of the usecase is rsync between two physical filesystems; but in
> > this particular use case the export
> > is readonly (rootfs).  As trond mentioned Volatile FHs are fine in
> > the case of readonly exports.
> > Is it something we can consider for upstream? VFH only for readonly
> > exports.?
> 
> The client has no way of knowing that an export is read only.  (Or that
> the server guarantees the safety of looking up names again in the more
> general cases Neil describes.)  Unless we decide that a server is making
> an implicit guarantee of that just by exposing volatile filehandles at
> all.  Doesn't sound like the existing spec really says that, though.

NFSv4.1 introduces the 'fs_status' recommended attribute (see section
11.11 in RFC5661), which does, in fact, allow the client to deduce that
an export is read-only/won't ever change.

> If an examination of existing implementations and/or some sort of new
> spec language could reassure us that servers will only ever expose
> volatile filehandles when it's safe to do so, then maybe it would make
> sense for the client to implement volatile filehandle recovery?
> 
> But if there's a chance of "unsafe" servers out there, then it would
> seem like a trap for the unwary user....
> 
> Your rootfs's probably aren't terribly large--could you copy around
> compressed block-level images instead of doing rsync?

Agreed.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

