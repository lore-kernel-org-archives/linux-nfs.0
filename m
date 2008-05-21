From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 6/6] SUNRPC: Display some debugging information as text
	rather than numbers
Date: Wed, 21 May 2008 16:40:35 -0400
Message-ID: <1211402435.12989.5.camel@localhost>
References: <20080521180231.3295.84997.stgit@ellison>
	 <20080521181620.3295.2298.stgit@ellison>
	 <20080521195041.GC6712@fieldses.org>
	 <0276F8AD-8401-4991-803F-581E37223397@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22865 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764337AbYEUUki convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2008 16:40:38 -0400
In-Reply-To: <0276F8AD-8401-4991-803F-581E37223397@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-05-21 at 16:37 -0400, Chuck Lever wrote:
> >> +		task->tk_pid, task->tk_flags, task->tk_status,
> >> +		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
> >> +		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
> >> +		action, queue);
> >
> > "net/sunrpc/clnt.c: In function =E2=80=98rpc_show_task=E2=80=99:
> > net/sunrpc/clnt.c:1555: error: =E2=80=98queue=E2=80=99 undeclared (=
first use in this =20
> > function)
> > net/sunrpc/clnt.c:1555: error: (Each undeclared identifier is =20
> > reported only once
> > net/sunrpc/clnt.c:1555: error: for each function it appears in.)"
> >
> > Is that last "queue" supposed to be "rpc_waitq"???
>=20
> Yes... I fixed that already... was that in the version I sent out thi=
s =20
> afternoon?

Yep. Shall I fix it up, or do you want to resend?

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
