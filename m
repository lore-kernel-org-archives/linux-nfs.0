From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Fri, 30 Nov 2007 12:16:49 -0500
Message-ID: <20071130171649.GC14943@fieldses.org>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071130044553.GA29851@fieldses.org> <1196438368.5432.10.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbXK3RQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Nov 2007 12:16:51 -0500
In-Reply-To: <1196438368.5432.10.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 30, 2007 at 09:59:28AM -0600, Tom Tucker wrote:
>=20
> On Thu, 2007-11-29 at 23:45 -0500, J. Bruce Fields wrote:
> > On Thu, Nov 29, 2007 at 04:44:12PM -0600, Tom Tucker wrote:
> > > This patchset implements the RDMA Transport Driver for the=20
> [...snip...]
>=20
> I resent the two offending patches with fixes as required.

Thanks!  Applied and pushed out.

>=20
> > I still need the following to get it to compile.  Also, I'm getting
> > these warnings:
> >=20
> > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98dto_tasklet_f=
unc=E2=80=99:
> > net/sunrpc/svc_rdma_transport.c:232: warning: passing argument 2 of=
 =E2=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 of=
 =E2=80=98constant_test_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 of=
 =E2=80=98variable_test_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c:245: warning: passing argument 2 of=
 =E2=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rq_comp_handl=
er=E2=80=99:
> > net/sunrpc/svc_rdma_transport.c:271: warning: passing argument 2 of=
 =E2=80=98set_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98sq_comp_handl=
er=E2=80=99:
> > net/sunrpc/svc_rdma_transport.c:382: warning: passing argument 2 of=
 =E2=80=98set_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rdma_cma_hand=
ler=E2=80=99:
> > net/sunrpc/svc_rdma_transport.c:617: warning: passing argument 2 of=
 =E2=80=98clear_bit=E2=80=99 from incompatible pointer type
> > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98svc_rdma_acce=
pt=E2=80=99:
> > net/sunrpc/svc_rdma_transport.c:848: warning: passing argument 2 of=
 =E2=80=98set_bit=E2=80=99 from incompatible pointer type
> >=20
>=20
> I'm mystified as to why I didn't get these warnings. I built on a 64 =
bit
> machine. It seems like that would give the warning since unsigned lon=
g
> isn't even the same size as int.

Yeah, I can't see how any compiler could miss that.  How do you usually
build?

--b.
