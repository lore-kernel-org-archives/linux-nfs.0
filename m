Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58262 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494AbaHUBLK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2014 21:11:10 -0400
Date: Thu, 21 Aug 2014 11:11:00 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Message-ID: <20140821111100.0fc7e3c9@notabene.brown>
In-Reply-To: <1408581916.4029.15.camel@leira.trondhjem.org>
References: <20140818061727.1449.89101.stgit@notabene.brown>
	<20140818062254.1449.99502.stgit@notabene.brown>
	<1408581916.4029.15.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/IQM=WVGvJ.VZoNswHshEwxv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/IQM=WVGvJ.VZoNswHshEwxv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 20 Aug 2014 20:45:16 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, 2014-08-18 at 16:22 +1000, NeilBrown wrote:
> > Support for loop-back mounted NFS filesystems is useful when NFS is
> > used to access shared storage in a high-availability cluster.
> >=20
> > If the node running the NFS server fails, some other node can mount the
> > filesystem and start providing NFS service.  If that node already had
> > the filesystem NFS mounted, it will now have it loop-back mounted.
> >=20
> > nfsd can suffer a deadlock when allocating memory and entering direct
> > reclaim.
> > While direct reclaim does not write to the NFS filesystem it can send
> > and wait for a COMMIT through nfs_release_page().
> >=20
> > This patch modifies nfs_release_page() and the functions it calls so
> > that if the COMMIT is sent to the local host (i.e. is routed over the
> > loop-back interface) then nfs_release_page() will not wait forever for
> > that COMMIT to complete.  This is achieved using a new flag
> > FLUSH_COND_CONNECTED.  When this is set the flush is conditional and
> > will only wait if the client is connected to a non-local server.
> >=20
> > Aborting early should be safe as kswapd uses the same code but never
> > waits for the COMMIT.
> >=20
> > Always aborting early could upset the balance of memory management so
> > when the commit was sent to the local host we still wait but with a
> > 100ms timeout.  This is enough to significantly slow down any process
> > that is allocating lots of memory and often long enough to let the
> > commit complete.
> >=20
> > In those rare cases where it is nfsd, or something that nfsd is
> > waiting for, that is calling nfs_release_page(), 100ms is not so long
> > that throughput will be seriously affected.
> >=20
> > When fail-over happens a remote (foreign) client will first become
> > disconnected and then turn into a local client.
> > To prevent deadlocks from happening at this point, we still have a
> > timeout when the COMMIT has been sent to a remote client. In this case
> > the timeout is longer (1 second).
> >=20
> > So when a node that has mounted a remote filesystem loses the
> > connection, nfs_release_page() will stop blocking and start failing.
> > Memory allocators will then be able to make progress without blocking
> > in NFS.  Any process which writes to a file will still be blocked in
> > balance_dirty_pages().
> >=20
> > This patch makes use of the new 'private' field in
> > "struct wait_bit_key" to store the start time of a commit, so the
> > 'action' function called by __wait_on_bit() knows how much longer
> > it is appropriate to wait.
> >=20
>=20
> This puts way too much RPC connection logic in the NFS layer: we really
> should not have to care. Is there any reason why we could not just use
> RPC_TASK_SOFTCONN to have the commit fail if the connection is broken?

I tried to keep as much in the RPC layer as I could....

There really is a big difference between talking to an 'nfsd' on the same
machine and talking to one on a different machine.  In the first case you
need to be cautious of deadlocks, in the second you don't.  That is a
difference that matters to NFS, not to RPC.

I guess we could always have a timeout, even when connected to a remote
server.  We would just end up blocking somewhere else when the server was n=
ot
responding.

I don't think SOFTCONN is really appropriate.  We don't want the COMMIT to
stop being retried.  We just don't want the memory reclaim code to block
waiting for the COMMIT.

>=20
> Note that all this has to come with a huge WARNING: all your data may be
> lost even if you think you just fsync()ed it. Is there any difference
> between doing this and using the 'async' export option on the knfsd
> side?
>=20

I don't think this patch risks losing data at all - that certainly isn't the
intent.
This patch only affects the behaviour of ->releasepage, and only allows it =
to
fail instead of block.  It is perfectly acceptable for releasepage to fail
and it doesn't result in data loss.  It just means that the page is busy.


Thanks,
NeilBrown

--Sig_/IQM=WVGvJ.VZoNswHshEwxv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/VHJDnsnt1WYoG5AQLtvw/+Ofb5rMGThNRbiVjPN/uh+m6DAKDRMAVE
/aKxteQCg9rPUIjmSehx7atQvq3DWUMfsOmbbqeLnkp5DamkcJdjSGlKH0PfMAWT
WIcQMUUcdyKkSMMZg25vWLiaziN9XVXEkGVajXzR8tovmh4nCSnCE4W/IxbEk4/k
ml/GM//2zA7mWvP6XSlbrvW8pFctFTbdFAd6NAU5K1bJ4rFEJkYD3iniN/ZjbVMb
WhtBxSGB6eM+cM1+z8oQTPAzrLDBPjHq5keUxdMM7w30IGJVTz0Jrew4lgLX0ThA
j8r0+CONZhTZ9JvjXbvuHPTUF7jhtHRukF3/yKVZvtZ784VhdUopHSA7RfXIdnAW
fEInicfZs67Gt8dFIHkGuNzBc45COp/0W93zD+cIc3wJLyRa7ek7/sM/dJc66tsp
RNz0EubQGrrMfKA40dygswDYo67ZTrCP6l1WP2mCMvRDUpfvnnKXdw3jDMicVh1K
rE5YjwqRQEQleLEh3aOdgXNAx0ZFaF0wu8X02ecCFFkBci1gUkdNqr7hg74tCvG1
S+3P1xANQ3yQalgo85v1COzsMbK1ISacNN7fCSrxwPYZGJPxbErvup4NFxwqA7kg
p357Sfv3iwfq6cAtq5EnP/X+aq/fshicGSaaxNz6wG75YJTJ6gtGCHPXJa1zX3P1
UmbSg1vq4dc=
=QV/b
-----END PGP SIGNATURE-----

--Sig_/IQM=WVGvJ.VZoNswHshEwxv--
