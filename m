From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Thu, 8 Jan 2009 21:57:16 -0500
Message-ID: <20090109025716.GA25831@fieldses.org>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:57929 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbZAIC5S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 21:57:18 -0500
In-Reply-To: <4966B92F.8060008-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> > [...]
> >     
> >     You can mitigate the problem by reading from a single file descriptor
> >     that's shared between processes (as mountd currently does), but that
> >     requires the read to always provide a buffer large enough to get the
> >     whole request in one atomic read.  That's less practical for gss
> >     init_sec_context calls, which could vary in size from a few hundred
> >     bytes to 100k or so.
> >   
> I'm confused -- doesn't the current cache_make_upcall() code allocate a
> buffer of length PAGE_SIZE and not allow it to be resized?

Yeah, sorry for the confusion: this was written as cleanup in
preparation for patches to support larger gss init_sec_context calls
needed for spkm3, which I'm told likes to send across entire certificate
trains in the initial NULL calls.  (But the spkm3 work is stalled for
now).

--b.
