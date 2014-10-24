Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:46291 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756582AbaJXNfE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2014 09:35:04 -0400
Received: by mail-qg0-f43.google.com with SMTP id j107so974499qga.30
        for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2014 06:35:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 24 Oct 2014 09:34:59 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        bfields@fieldses.org
Subject: Re: [PATCH] nfsd: Ensure that NFSv4 always drops the connection
 when dropping a request
Message-ID: <20141024093459.70a29d80@tlielax.poochiereds.net>
In-Reply-To: <20141024072644.6643f9ed@tlielax.poochiereds.net>
References: <CAHQdGtQM7E37gFeLopQiNcvC+QH7MPVMdYnwYhScL65rq=xHxQ@mail.gmail.com>
	<1414145308-11196-1-git-send-email-trond.myklebust@primarydata.com>
	<20141024072644.6643f9ed@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Oct 2014 07:26:44 -0400
Jeff Layton <jlayton@primarydata.com> wrote:

> On Fri, 24 Oct 2014 13:08:28 +0300
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > Both RFC3530 and RFC5661 impose a requirement on the server that it MUST NOT
> > drop a request unless the connection is broken.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfsd/nfs4proc.c         | 6 ++++++
> >  include/linux/sunrpc/svc.h | 1 +
> >  net/sunrpc/svc.c           | 4 ++++
> >  3 files changed, 11 insertions(+)
> > 
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index cdeb3cfd6f32..500ac76662a8 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -1960,6 +1960,11 @@ static const char *nfsd4_op_name(unsigned opnum)
> >  	return "unknown_operation";
> >  }
> >  
> > +static void nfsd4_dropme(struct svc_rqst *rqstp)
> > +{
> > +	svc_close_xprt(rqstp->rq_xprt);
> > +}
> > +
> >  #define nfsd4_voidres			nfsd4_voidargs
> >  struct nfsd4_voidargs { int dummy; };
> >  
> > @@ -1989,6 +1994,7 @@ struct svc_version	nfsd_version4 = {
> >  		.vs_nproc	= 2,
> >  		.vs_proc	= nfsd_procedures4,
> >  		.vs_dispatch	= nfsd_dispatch,
> > +		.vs_dropme	= nfsd4_dropme,
> >  		.vs_xdrsize	= NFS4_SVC_XDRSIZE,
> >  		.vs_rpcb_optnl	= 1,
> >  };
> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> > index 21678464883a..824656da1f6d 100644
> > --- a/include/linux/sunrpc/svc.h
> > +++ b/include/linux/sunrpc/svc.h
> > @@ -400,6 +400,7 @@ struct svc_version {
> >  	 * vs_dispatch == NULL means use default dispatcher.
> >  	 */
> >  	int			(*vs_dispatch)(struct svc_rqst *, __be32 *);
> > +	void			(*vs_dropme)(struct svc_rqst *);
> >  };
> >  
> >  /*
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index ca8a7958f4e6..09136abfef26 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1071,6 +1071,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> >  	struct svc_version	*versp = NULL;	/* compiler food */
> >  	struct svc_procedure	*procp = NULL;
> >  	struct svc_serv		*serv = rqstp->rq_server;
> > +	void (*dropme)(struct svc_rqst *rqstp) = NULL;
> >  	kxdrproc_t		xdr;
> >  	__be32			*statp;
> >  	u32			prog, vers, proc;
> > @@ -1151,6 +1152,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> >  	if (vers >= progp->pg_nvers ||
> >  	  !(versp = progp->pg_vers[vers]))
> >  		goto err_bad_vers;
> > +	dropme = versp->vs_dropme;
> >  
> >  	procp = versp->vs_proc + proc;
> >  	if (proc >= versp->vs_nproc || !procp->pc_func)
> > @@ -1228,6 +1230,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> >   dropit:
> >  	svc_authorise(rqstp);	/* doesn't hurt to call this twice */
> >  	dprintk("svc: svc_process dropit\n");
> > +	if (dropme != NULL)
> > +		dropme(rqstp);
> >  	return 0;
> >  
> >  err_short_len:
> 
> (cc'ing Bruce too...)
> 
> I guess the theory here is that the client sent the request, and got a
> TCP ACK and then the server never responded because it dropped the
> request? That sounds plausible and we almost certainly want something
> like the above for v4.0.
> 
> If the above patch fixes Christoph's problem with v4.1 though, then I
> think we'll need more investigation into why. I don't see a way to get
> a dropped request with v4.1. Those mainly occur due to interaction with
> the DRC (disabled for v4.1) or with svc_defer (disabled for all v4
> requests).
> 
> Is it possible that one of the nfsd threads is just hung while
> processing an RPC and that's why you're not getting a response?
> 

Ok, I'm able to reproduce this too and got a network trace. I think
Trond is correct as to the cause:

I see a SETATTR call go out and then see a TCP ACK for it a little
later, but didn't see a reply sent for it.

I sprinkled in some printks around the "dropit" codepath above and in
some other areas however and none of them fired. So while Trond's patch
looks like it might be correct, I don't think it'll fix the problem I'm
seeing.

Sniffing a little later, it seems like the server replies are being
delayed somehow:

362 450.126141          ::1 -> ::1          NFS 234 V4 Call SEQUENCE
363 450.126211          ::1 -> ::1          NFS 170 V4 Reply (Call In 349) SEQUENCE
364 450.126253          ::1 -> ::1          TCP 98 [TCP Dup ACK 362#1] 826→2049 [ACK] Seq=5577 Ack=1 Win=23025 Len=0 TSval=546384 TSecr=4294762921 SLE=131289 SRE=135581
365 450.126302          ::1 -> ::1          TCP 65550 [TCP Out-Of-Order] 2049→826 [ACK] Seq=1 Ack=5577 Win=16001 Len=65464 TSval=546384 TSecr=546384
366 450.126320          ::1 -> ::1          TCP 266 [TCP Out-Of-Order] 2049→826 [PSH, ACK] Seq=65465 Ack=5577 Win=16001 Len=180 TSval=546384 TSecr=546384[Reassembly error, protocol TCP: New fragment overlaps old data (retransmission?)]
367 450.327131          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5577 Win=16001 Len=65464 TSval=546585 TSecr=546384
368 450.729997          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5577 Win=16001 Len=65464 TSval=546988 TSecr=546384
369 451.536010          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5577 Win=16001 Len=65464 TSval=547794 TSecr=546384
370 453.149981          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5577 Win=16001 Len=65464 TSval=549408 TSecr=546384
371 455.150167          ::1 -> ::1          NFS 234 V4 Call SEQUENCE
372 455.150235          ::1 -> ::1          NFS 170 V4 Reply (Call In 362) SEQUENCE
373 455.150279          ::1 -> ::1          TCP 98 [TCP Dup ACK 371#1] 826→2049 [ACK] Seq=5713 Ack=1 Win=23025 Len=0 TSval=551408 TSecr=4294762921 SLE=131289 SRE=135665
374 455.350978          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5713 Win=16001 Len=65464 TSval=551609 TSecr=551408
375 455.753946          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5713 Win=16001 Len=65464 TSval=552012 TSecr=551408
376 456.559960          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5713 Win=16001 Len=65464 TSval=552818 TSecr=551408
377 458.173955          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5713 Win=16001 Len=65464 TSval=554432 TSecr=551408
378 461.398011          ::1 -> ::1          TCP 65550 [TCP Retransmission] 2049→826 [ACK] Seq=1 Ack=5713 Win=16001 Len=65464 TSval=557656 TSecr=551408

Note that the reply in 372 is a reply to the call in 362 even though it
was sent just after the *next* SEQUENCE call came in. There are also a
bunch of TCP retransmissions. Later SEQUENCE replies follow a similar
pattern.

Looking at /proc/meminfo, it looks like I have plenty of free memory so
I don't think this is a memory exhaustion situation. All of the nfsds
seem idle (I have 64 running) and the CPUs aren't especially busy.

It "smells" sort of like something is wrong in the lower networking
layers. That said, I'm not quite ready to point fingers there yet. I'll
do a bit more debugging and see what I can find.

Stay tuned...
-- 
Jeff Layton <jlayton@primarydata.com>
