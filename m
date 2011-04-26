Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55092 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753391Ab1DZQwY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2011 12:52:24 -0400
Subject: Re: pNFS read/write behavior change in 2.6.39
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <4DB6D8C3.1070801@desy.de>
References: <4DB6D0CC.4050601@desy.de>
	 <1303828194.1785.21.camel@lade.trondhjem.org>  <4DB6D8C3.1070801@desy.de>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Apr 2011 12:52:16 -0400
Message-ID: <1303836736.1785.27.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-04-26 at 16:37 +0200, Tigran Mkrtchyan wrote:
> On 04/26/2011 04:29 PM, Trond Myklebust wrote:
> > On Tue, 2011-04-26 at 16:03 +0200, Tigran Mkrtchyan wrote:
> >> I run 2.6.39-0.rc4.git2.0 build for fedora-16 build by redhat.
> >> Probably Steve and Bruce can comment on the patch set.
> >>
> >> My observation is that state id provided by client on read to
> >> DS dit not contain correct stateid:
> >>
> >> struct stateid4 {
> >>           uint32_t        seqid;
> >>           opaque          other[12];
> >> };
> >>
> >> The seqid equals to zero when client send it to DS which is not the
> >> value returned on OPEN.
> > Why do you think this is a bug? Section 8.2.2 of RFC5661 not only allows
> > this behaviour, it actually suggests it is appropriate for READ and
> > WRITE since it means that the server isn't forced to constantly check
> > the seqid value.
> Well, It's not a bug, but it's not the behavior we was testing at 
> Connectathon.
> My expectation was that during interoperability testing we catch such 
> changes.

My expectation is that everyone is coding to the spec, and not to
specific client or server behaviours. The main goal of interoperability
testing should be to discover deviations from the spec and/or incomplete
implementations.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

