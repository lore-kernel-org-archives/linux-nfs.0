From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSERR_NOSPC nfs-client bug
Date: Mon, 17 Mar 2008 23:09:35 -0400
Message-ID: <1205809775.22258.9.camel@heimdal.trondhjem.org>
References: <200803172021.08327.nfs@share-foo.com>
	 <47DF1E5C.9090607@melbourne.sgi.com> <200803172050.22223.nfs@share-foo.com>
	 <47DF2415.6070802@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org, linux-nfs@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:43964 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752114AbYCRDJl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2008 23:09:41 -0400
In-Reply-To: <47DF2415.6070802-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-03-18 at 13:08 +1100, Greg Banks wrote:
> Ray Ferguson wrote:
> > On Monday 17 March 2008 20:43, Greg Banks wrote:
> >   
> >> It doesn't ignore ENOSPC, it reports it on close().  Of course this is
> >> often several gigabytes of lost data too late.
> >>     
> >
> > In our case, the thrashing it gave our Linux NFS cluster was severe enough to  
> > take it out of commission.  The lost data from the file transfer that 
> > triggered the event was the least of our worries.
> >
> >   
> Agreed, it sucks.

Try a more recent kernel: 2.6.24 and more recent will report these
errors more promptly.

Trond

