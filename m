Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30965 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754648Ab3BGQcW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 11:32:22 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Date: Thu, 7 Feb 2013 16:32:20 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91836525F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
 <1360248701-23963-3-git-send-email-jlayton@redhat.com>
 <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
 <20130207160032.GF3222@fieldses.org>
In-Reply-To: <20130207160032.GF3222@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Thursday, February 07, 2013 11:01 AM
> To: Chuck Lever
> Cc: Jeff Layton; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
> request
> 
> On Thu, Feb 07, 2013 at 10:51:02AM -0500, Chuck Lever wrote:
> >
> > On Feb 7, 2013, at 9:51 AM, Jeff Layton <jlayton@redhat.com> wrote:
> >
> > > Now that we're allowing more DRC entries, it becomes a lot easier to
> > > hit problems with XID collisions. In order to mitigate those,
> > > calculate the crc32 of up to the first 256 bytes of each request
> > > coming in and store that in the cache entry, along with the total
> > > length of the request.
> >
> > I'm happy to see a checksummed DRC finally become reality for the
> > Linux NFS server.
> >
> > Have you measured the CPU utilization impact and CPU cache footprint
> > of performing a CRC computation for every incoming RPC?
> 
> Note this is over the first 256 bytes of the request--which we're probably just
> about to read for xdr decoding anyway.

- Would it make sense perhaps to generate the checksum as you are reading the data?
- Also, is 256 bytes sufficient? How far does that get you with your average WRITE compound?
- Could the integrity checksum in RPCSEC_GSS/krbi be reused as a DRC checksum?

Cheers
   Trond
