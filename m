From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Sat, 07 Feb 2009 11:23:24 -0500
Message-ID: <1234023804.17241.14.camel@heimdal.trondhjem.org>
References: <20090206.140714.201930500.davem@davemloft.net>
	 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
	 <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
	 <20090206.192243.47948705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org, chuck.lever@oracle.com,
	bfields@fieldses.org, trond@netapp.com, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120AbZBGQXp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Feb 2009 11:23:45 -0500
In-Reply-To: <20090206.192243.47948705.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-02-06 at 19:22 -0800, David Miller wrote:
> From: "Ilpo J=C3=A4rvinen" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
> Date: Sat, 7 Feb 2009 00:58:44 +0200 (EET)
>=20
> > I think your "English" is too strict requirement.
>=20
> I absolutely and whole-heartedly agree.  This set of
> requirements is beyond rediculious and will do nothing
> but deter people from contributing.
>=20
> So unless that's what the goal is...
>=20
> Anyways, I'll be applying Ilpo's great changes to the
> net-next-2.6 GIT tree, without putting him through the
> ringer like this.

No. I find it quite unacceptable for the networking group to circumvent
the standard Linux review process in this manner. If you plan to push a
patch into the sunrpc code against the wishes of the community and
people that maintain that code then I'll be petitioning Linus to revert
it on general principle as soon as it hits his tree.

Like it or not, the changelog _is_ a part of the patch that is subject
to review and comment, and while I like the rest of the patch, I will
support Chuck and Bruce's comments that putting a bunch of diffstat
output into the changelog is not a substitute for a simple sentence. Al=
l
it takes is

"
Save 147 lines by moving the common code from xs_udp_write_space() and
xs_tcp_write_space() into a separate helper.

S-o-b: Ilpo....
"

and everyone will be happy. So please stop making a storm in a teacup
out of this...

Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
