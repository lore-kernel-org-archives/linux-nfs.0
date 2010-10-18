From: =?UTF-8?B?Q2zDoXVkaW8=?= Martins <ctpm-s6mEjpzMaPUVhHzd4jOs4w@public.gmane.org>
Subject: Re: NFS sillyrename side effect
Date: Mon, 18 Oct 2010 16:44:14 +0100
Message-ID: <20101018164414.ec860360.ctpm@ist.utl.pt>
References: <1287362142-sup-777@au1.ibm.com>
	<20101018101059.574b715a@corrin.poochiereds.net>
	<20101018154811.768baeb5.ctpm@ist.utl.pt>
	<20101018155344.6e50dbb9.ctpm@ist.utl.pt>
	<20101018110138.5f5001eb@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian Munsie <imunsie-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>,
	Trond Myklebust <trond.myklebust@netapp.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Scott Romanowski <romansc@us.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.ist.utl.pt ([193.136.128.21]:38474 "EHLO smtp1.ist.utl.pt"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932647Ab0JRPoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 11:44:16 -0400
In-Reply-To: <20101018110138.5f5001eb-4QP7MXygkU+dMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 18 Oct 2010 11:01:38 -0400 Jeff Layton <jlayton@redhat.com> wro=
te:
> On Mon, 18 Oct 2010 15:53:44 +0100
> Cl=C3=A1udio Martins <ctpm-s6mEjpzMaPUVhHzd4jOs4w@public.gmane.org> wrote:
>=20
> > >=20
> > >  So, theoretically, could one modify the code to selectively disa=
ble
> > > silly rename on a client, when it knows it is talking v4 with the
> > > server?
> > >=20
> >=20
> >  BTW, to clarify, I'm assuming a scenario where the server is
> > configured to talk v4 only, which I suspect should be common, at le=
ast
> > when you're relying on v4 kerberos security.
> >=20
>=20
> Sadly, no...
>=20
> The server does generally hold the file open as long as the client ha=
s
> the file open. So, you could delete the file while nfsd has it open a=
nd
> everything would probably still work.
>=20
> Suppose though that the server crashes and reboots. When it comes bac=
k
> up, fsck figures out that the file has been unlinked and frees the
> blocks on the disk. Now you can't reclaim the state on the open file.
>=20
> We're pretty much stuck with silly-renaming even for v4.
>=20

 Jeff,

 Thank you for the explanation, you make a good point.

Best regards

Cl=C3=A1udio

