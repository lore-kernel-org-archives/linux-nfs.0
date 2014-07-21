Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41094 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbaGUDgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jul 2014 23:36:00 -0400
Date: Mon, 21 Jul 2014 13:35:51 +1000
From: NeilBrown <neilb@suse.de>
To: Tejun Heo <tj@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: state manager thread must start running.
Message-ID: <20140721133551.515f1d26@notabene.brown>
In-Reply-To: <20140715145111.GA18661@htj.dyndns.org>
References: <20140715163942.1d94304f@notabene.brown>
	<20140715074942.GA6166@infradead.org>
	<20140715181317.2de14c51@notabene.brown>
	<20140715145111.GA18661@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ABzOUlXWN645H/nIBfgf=mh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ABzOUlXWN645H/nIBfgf=mh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Jul 2014 10:51:11 -0400 Tejun Heo <tj@kernel.org> wrote:

> Hello, Neil.
>=20
> On Tue, Jul 15, 2014 at 06:13:17PM +1000, NeilBrown wrote:
> > Could do that (or per-client) but it doesn't really buy us anything doe=
s it?
>=20
> It does buy some.
>=20
> 1. The kworker threads are more likely to be cache-hot than explicit
>    kthreads.
>=20
> 2. Workqueue is a lot eaiser to get right in terms of synchronization
>    and freezing.
>=20
> 3. Workqueue mandates well-defined boundaries between separate
>    execution instances which often makes it a lot easier to implement
>    and update kernel-wide features such as like freezer and runtime
>    kernel patching.
>=20
> > The state manager assumes it is single threads, so it would need to be
> > a single-threaded workqueue with always at least one thread running.
> > That is much the same as a kthread.
> >=20
> > And then there is that fact that the current code explicitly enabled SI=
GKILL
> > and maybe that is important.
>=20
> If SIGKILL handling is mandatory (really?), kthread_worker can be used
> for #2 and #3.
>=20
> Thanks.
>=20

(kthread_worker doesn't seem to be very well documented, but I think I see
what it does).

The only reason I can think for that SIGKILL might be important is that when
a server is not responding, a process that it trying to talk to it will only
give up if it gets a fatal signal.  So if state recovery starts for a server
that cannot be contacted, the thread doing the recovery will block until the
server comes back or until it received SIGKILL.

I cannot see anything that would generate such a SIGKILL except the broadca=
st
SIGKILL at shutdown.
So maybe the purpose of=20
	allow_signal(SIGKILL);
is to ensure that when the machine is shutdown, the -manager thread actually
dies.
But I'm not confident of this explanation.  If this were the issue I would
expect nfs_umount_begin to be sending SIGKILL too. But it just does
rpc_killall_tasks- maybe that is enough.  If so, is SIGKILL really needed.

Trond: can you provide some wisdom?  Is SIGKILL important for the manager
threads?
If so, would you prefer a thread that uses kthread_worker, or one that works
more like the current code?
If not, would you be happy with a fully workqueue based solution?

Thanks,
NeilBrown


--Sig_/ABzOUlXWN645H/nIBfgf=mh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8yKlznsnt1WYoG5AQI0TBAAtjvmtRYsHSWIbEybLdFxgQiJ0vg23wJt
KfoI5nKRtO8iqgqOaEg89G9xNhkHMrs5YutWvVG0WzcizafC7SnoVjEOeuLFDt4P
NCBTIBoqRn3F1jaf/MpZV3ClOgiTOZzT+sebV8fD7LdmGHKhrM4tjCQxhqdy9s9Y
HZdNba/m+4B6Zmhsypd4Z9Kc28rkSBSgAEhk5BAXe9yE0ear3elAGD/gIQ58BnWv
1qJyagXaFKwznh/5MQZ5UWYl/0mzCaDZnk8Ki5fzu00rmICSdhK4S89lC+LJNwDd
+QVgWuHgFvpoOIRny8FkWE5/BplA7SnjS4380MwJo4JFh1MfrSFUlAHyK8HAD0kF
LE5PxXtrotO+QpDAHMq+6FaQ9TqcGEmOL+9gX0GqTxNB7WQLDsC48qSFhgBJCX48
IR4mYEnaMx5MLpREDjYfF2ouc3ioK1mY30HgJ1Xm0Uvl5qnybulgghhP6ipO7z3s
PywZB/glA9YNVZmWNwoskYvcMwBIXTuvswA7OKdu24RkTyxHd+4ys/x6bGBHGput
Rq52s1lOiAOqt3s5lY7a8Gv1M+rQEFVjIpspEd6AF5uChoNcxQBFQTuGltg3hGK+
8xfq3qsCFXnLMyVRlhqOX7PM/ARL38NcUI7IGEeOGOwu2pB9qyMfjDC9loGUIjrb
/Q3hFCFxa0o=
=Km3s
-----END PGP SIGNATURE-----

--Sig_/ABzOUlXWN645H/nIBfgf=mh--
