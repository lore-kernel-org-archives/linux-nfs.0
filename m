From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
	referrals and migration
Date: Thu, 20 Aug 2009 18:33:50 -0400
Message-ID: <20090820223349.GE2451@fieldses.org>
References: <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com> <20090820210352.GB2451@fieldses.org> <1250807011.6514.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33213 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670AbZHTWds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 18:33:48 -0400
In-Reply-To: <1250807011.6514.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2009 at 06:23:31PM -0400, Trond Myklebust wrote:
> On Thu, 2009-08-20 at 17:03 -0400, J. Bruce Fields wrote:
> > On Wed, Aug 19, 2009 at 07:38:53PM -0400, Trond Myklebust wrote:
> > > The NFSv4 and NFSv4.1 protocols both allow for the redirection of=
 a client
> > > from one server to another in order to support filesystem migrati=
on and
> > > replication. For full protocol support, we need to add the abilit=
y to
> > > convert a DNS host name into an IP address that we can feed to th=
e RPC
> > > client.
> >=20
> > Your current nfs-for-2.6.32 doesn't compile for me:
> >=20
> > 	In file included from fs/nfs/cache_lib.c:14:
> > 	include/linux/sunrpc/rpc_pipe_fs.h:35: error: field =E2=80=98queue=
_timeout=E2=80=99 has incomplete type
> >=20
> > (I wonder why you weren't seeing this?)
>=20
> Odd. Neither Ubuntu 9.04 nor Fedora 11 flagged the above error when I
> compiled it.
> A few days ago I had the same issue with some of Benny's stuff. He sw=
ore
> he couldn't reproduce the error with his copy of gcc, whereas mine
> flagged it immediately.
>=20
> Anyhow, I'm committing your fix. Thanks for reporting it.

Maybe there's an include of linux/workqueue.h (hidden somewhere deep in
the includes from cache_lib.c) that's under a config option?

--b.
