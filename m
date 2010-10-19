Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42706 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885Ab0JSPU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Oct 2010 11:20:28 -0400
Date: Tue, 19 Oct 2010 11:20:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@Oracle.com>
Cc: Pavel Emelyanov <xemul@parallels.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 9/13] sunrpc: Merge the xs_bind code
Message-ID: <20101019152025.GB16742@fieldses.org>
References: <9D130D08-1FD3-4088-AB43-8CEFFE6476B3@oracle.com>
 <20101015180852.GC18869@fieldses.org>
 <068F3C9A-2930-46F7-AC15-EB71ADA1933F@oracle.com>
 <20101018211537.GC4740@fieldses.org>
 <20101018214305.GE4740@fieldses.org>
 <4480316F-74A4-4157-B685-056FD958890E@oracle.com>
 <20101018215758.GH4740@fieldses.org>
 <C254B855-0C70-4989-8559-143EB388D2EA@oracle.com>
 <20101018235509.GI4740@fieldses.org>
 <3E07FB7E-0697-409E-B51E-A3B310F7B065@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3E07FB7E-0697-409E-B51E-A3B310F7B065@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 19, 2010 at 10:35:51AM -0400, Chuck Lever wrote:
> 
> On Oct 18, 2010, at 7:55 PM, J. Bruce Fields wrote:
> 
> > On Mon, Oct 18, 2010 at 06:37:01PM -0400, Chuck Lever wrote:
> >> 
> >> The calling convention for rpc_create() allows this.  Notice in xs_setup_xprt() the source address is copied only if the args->srcaddr pointer is not NULL.  If it _is_ NULL, then the sock_xprt's srcaddr field should be filled with all zeros (which is the ANYADDR in both IPv4 and IPv6) because we allocate the new sock_xprt structure via kzalloc().  But the sa_family field is left zero as well in this case.
> >> 
> >> This is where the actual bug is, I think.  When srcaddr is NULL, instead of leaving that srcaddr field uninitialized in xs_setup_xprt(), it should plant an appropriate ANYADDR address there.  The family of that ANYADDR address is determined by the family of dstaddr, which is always initialized before this function is called.  I can send you a simple example patch that might apply before Pavel's work, if you like.
> >> 
> >> In the current code, the fact that ANYADDR just happens to be all zeroes saved our ass on this one.
> > 
> > It sounds like you're saying that before we ensured that fields other
> > tha .sin_family were zero in one way (with the automatic initialiation
> > of myaddr above), and now ensure it in another (kzalloc of the thing we
> > copy from)--I'm not sure the difference is as important as all that?
> 
> When the ULPs did not provide a source address, we've always used a zeroed out sockaddr.  That's marginally incorrect, but since ANYADDR is all zeroes, functionally it doesn't matter.  Formerly xs_bind?() copied only the address part (not the family or the port) when building the bind address.  With Pavel's changes it's copying more than just the address field in the source address.
> 
> All I'm saying is that the transport's source address should always be fully initialized (family included) at xprt setup time.
> 
> > But, honestly, I'm not following all this--I'll happily take whatever
> > revision you and Pavel want to give me, either incremental or as a
> > replacement for the 17 patches.
> 
> It's a minor change.  I can send you something later today to try.

OK, thanks.  I think it'll be easiest to proceed if I just go ahead and
commit what we've got so far; so I've just pushed out Pavel's stuff to

	git://linux-nfs.org/~bfields/linux.git for-2.6.37

Incremental patches on top of that welcomed.

--b.
