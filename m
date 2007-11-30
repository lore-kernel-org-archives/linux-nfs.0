From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Fri, 30 Nov 2007 14:50:03 -0600
Message-ID: <1196455803.5432.45.camel@trinity.ogc.int>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
	 <20071130044553.GA29851@fieldses.org>
	 <1196438368.5432.10.camel@trinity.ogc.int>
	 <20071130171649.GC14943@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:45850 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751667AbXK3Up6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 15:45:58 -0500
In-Reply-To: <20071130171649.GC14943@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2007-11-30 at 12:16 -0500, J. Bruce Fields wrote:
> On Fri, Nov 30, 2007 at 09:59:28AM -0600, Tom Tucker wrote:
> >=20

[...snip...]

> Thanks!  Applied and pushed out.
>=20

thank you too.

> >=20
> > > I still need the following to get it to compile.  Also, I'm getti=
ng
> > > these warnings:
> > >=20

So here's an irony for you... if you're on a 32 bit x86 platform you ge=
t
this definition for test_and_clear_bit:

*** include/asm-x86/bitops_32.h:
test_and_clear_bit[222]        static inline int test_and_clear_bit(int=
 nr, volatile unsigned long * addr)

which will give you an error if you use &int, but if you're on a 64b x8=
6 platform,
you get this definition:

*** include/asm-x86/bitops_64.h:
test_and_clear_bit[211]        static inline int test_and_clear_bit(int=
 nr, volatile void *addr)

That's why I didn't see the warning, because the parameter type on a 64=
b
system is void *.  This looks like a bug to me, but maybe someone can
explain the reasoning?

> > > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98dto_tasklet=
_func=E2=80=99:
> > > net/sunrpc/svc_rdma_transport.c:232: warning: passing argument 2 =
of =E2=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 =
of =E2=80=98constant_test_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 =
of =E2=80=98variable_test_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c:245: warning: passing argument 2 =
of =E2=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rq_comp_han=
dler=E2=80=99:
> > > net/sunrpc/svc_rdma_transport.c:271: warning: passing argument 2 =
of =E2=80=98set_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98sq_comp_han=
dler=E2=80=99:
> > > net/sunrpc/svc_rdma_transport.c:382: warning: passing argument 2 =
of =E2=80=98set_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rdma_cma_ha=
ndler=E2=80=99:
> > > net/sunrpc/svc_rdma_transport.c:617: warning: passing argument 2 =
of =E2=80=98clear_bit=E2=80=99 from incompatible pointer type
> > > net/sunrpc/svc_rdma_transport.c: In function =E2=80=98svc_rdma_ac=
cept=E2=80=99:
> > > net/sunrpc/svc_rdma_transport.c:848: warning: passing argument 2 =
of =E2=80=98set_bit=E2=80=99 from incompatible pointer type
> > >=20
> >=20
> > I'm mystified as to why I didn't get these warnings. I built on a 6=
4 bit
> > machine. It seems like that would give the warning since unsigned l=
ong
> > isn't even the same size as int.
>=20
> Yeah, I can't see how any compiler could miss that.  How do you usual=
ly
> build?
>=20
> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

