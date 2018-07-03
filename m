Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:40074 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932120AbeGCCot (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2018 22:44:49 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: RDMA connection closed and not re-opened
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
Date: Mon, 2 Jul 2018 22:44:43 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chucklever@gmail.com>
Message-Id: <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu> <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com> <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
To: admin@genome.arizona.edu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 2, 2018, at 7:22 PM, admin@genome.arizona.edu wrote:
>=20
> Thanks Chuck for your input, let me address it below like normal for maili=
ng lists.  Although I'm confused as to why my message hasn't shown up on the=
 mailing list, even though I'm subscribed with this address... I've written t=
o owner-linux-nfs@vger.kernel.org regarding this discrepancy and it was reje=
cted as spam so now i'm waiting to hear from postmaster@vger.kernel.org, so I=
 guess I'll need to continue to CC you as well in the time being since your r=
esponses show up on the mailing list at least...
>=20
>=20
> Chuck Lever wrote on 06/29/2018 08:04 AM:
> > These are informational messages that are typical of network
> > problems or maybe the server has failed or is overloaded. I'm
> > especially inclined to think this is not a client issue because it
> > happens on multiple clients at around the same time.
>=20
> Yes it makes sense to be a server problem, however our server is more than=
 capable of handling this I would think.  Although it is an older server, it=
 still has 2x 6-core Intel Xeon E5-2620 v2 @ 2.10GHz with 128GB of RAM and m=
aybe 10% utilization normally.  I have not watched the server when we start t=
hese daligner jobs so that could be something I look for to see if I notice a=
ny bottlenecks... what is a typical bottleneck for NFS/RDMA?

Please review all of my last email. I concluded the likely culprit is a soft=
ware bug, not server overload.


> > If there are no other constraints on your NFS server's kernel /
> > distribution, I recommend upgrading it to a recent update of CentOS
> > 7 (not simply a newer CentOS 6 release).
>=20
> Unfortunately CentOS doesn't support upgrading from 6 to 7 and this machin=
e is too critical to take down for a fresh installation/reconfiguration, so I=
 have a feeling we'll need to figure out how to get the 6.9 kernel working. =
 I will try updating to the latest kernel on all of the nodes to see if it h=
elps.

If CentOS 6 is required, CentOS / Red Hat really does need to be involved as=
 you troubleshoot. Any code changes will necessitate a new kernel build that=
 only they can provide.

