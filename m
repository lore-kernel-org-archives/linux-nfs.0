From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: RE: [PATCH RFC 02/10] nfsd41: sunrpc: Added rpc server-side backchannel handling
Date: Mon, 24 Aug 2009 16:50:33 -0700
Message-ID: <B9364369CA66BF45806C2CD86EAB8BA603B4FDE3@SACMVEXC3-PRD.hq.netapp.com>
References: <4A8C9992.2000505@panasas.com> <1250728463-28511-1-git-send-email-bhalevy@panasas.com> <20090824233419.GE8532@fieldses.org> <1251157347.6325.364.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Benny Halevy" <bhalevy@panasas.com>, <linux-nfs@vger.kernel.org>,
	<pnfs@linux-nfs.org>, "Iyer, Rahul" <Rahul.Iyer@netapp.com>,
	"Sager, Mike" <Mike.Sager@netapp.com>,
	"Marc Eshel" <eshel@almaden.ibm.com>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38447 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbZHXXur convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2009 19:50:47 -0400
In-Reply-To: <1251157347.6325.364.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Myklebust, Trond
> Sent: Monday, August 24, 2009 4:42 PM
> To: J. Bruce Fields
> Cc: Benny Halevy; linux-nfs@vger.kernel.org; pnfs@linux-nfs.org; Iyer,
> Rahul; Sager, Mike; Marc Eshel; Labiaga, Ricardo; Adamson, Andy;
> Batsakis, Alexandros; Myklebust, Trond
> Subject: Re: [PATCH RFC 02/10] nfsd41: sunrpc: Added rpc server-side
> backchannel handling
> 
> > >
> > > When the call direction is a reply, copy the xid and call
direction
> into the
> > > req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header
> returns
> > > rpc_garbage.
> >
> > Looks mostly OK, though blocking the client rpciod on the
> > bc_send_request method may be a problem--rpciod normally tries not
to
> > sleep, and the other send_request methods look like they avoid it.
> 
> Agreed. Blocking on sending is unacceptable inside rpciod. Please
> either
> use non-blocking I/O, or use a different thread context for this.
> 

OK thanks, it makes sense. I ll take care of it

-alexandros

> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
