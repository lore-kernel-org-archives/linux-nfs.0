Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59154 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbaHUDEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2014 23:04:31 -0400
Date: Thu, 21 Aug 2014 13:04:22 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Message-ID: <20140821130422.769bf786@notabene.brown>
In-Reply-To: <20140821121544.10e11215@notabene.brown>
References: <20140818061727.1449.89101.stgit@notabene.brown>
	<20140818062254.1449.99502.stgit@notabene.brown>
	<1408581916.4029.15.camel@leira.trondhjem.org>
	<20140821111100.0fc7e3c9@notabene.brown>
	<CAHQdGtTLgD9Xw9T5fKAVK1VYEv+U9m_hKcw2SNvQrYEwnkZauQ@mail.gmail.com>
	<20140821121544.10e11215@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/kZzLnqPFNVuSz7bVwhsRGLJ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kZzLnqPFNVuSz7bVwhsRGLJ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 21 Aug 2014 12:15:44 +1000 NeilBrown <neilb@suse.de> wrote:

> On Wed, 20 Aug 2014 21:42:55 -0400 Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>=20
> > On Wed, Aug 20, 2014 at 9:11 PM, NeilBrown <neilb@suse.de> wrote:
> > > On Wed, 20 Aug 2014 20:45:16 -0400 Trond Myklebust
> > > <trond.myklebust@primarydata.com> wrote:
> > >
> > >> On Mon, 2014-08-18 at 16:22 +1000, NeilBrown wrote:
> > >> > Support for loop-back mounted NFS filesystems is useful when NFS is
> > >> > used to access shared storage in a high-availability cluster.
> > >> >
> > >> > If the node running the NFS server fails, some other node can moun=
t the
> > >> > filesystem and start providing NFS service.  If that node already =
had
> > >> > the filesystem NFS mounted, it will now have it loop-back mounted.
> > >> >
> > >> > nfsd can suffer a deadlock when allocating memory and entering dir=
ect
> > >> > reclaim.
> > >> > While direct reclaim does not write to the NFS filesystem it can s=
end
> > >> > and wait for a COMMIT through nfs_release_page().
> > >> >
> > >> > This patch modifies nfs_release_page() and the functions it calls =
so
> > >> > that if the COMMIT is sent to the local host (i.e. is routed over =
the
> > >> > loop-back interface) then nfs_release_page() will not wait forever=
 for
> > >> > that COMMIT to complete.  This is achieved using a new flag
> > >> > FLUSH_COND_CONNECTED.  When this is set the flush is conditional a=
nd
> > >> > will only wait if the client is connected to a non-local server.
> > >> >
> > >> > Aborting early should be safe as kswapd uses the same code but nev=
er
> > >> > waits for the COMMIT.
> > >> >
> > >> > Always aborting early could upset the balance of memory management=
 so
> > >> > when the commit was sent to the local host we still wait but with a
> > >> > 100ms timeout.  This is enough to significantly slow down any proc=
ess
> > >> > that is allocating lots of memory and often long enough to let the
> > >> > commit complete.
> > >> >
> > >> > In those rare cases where it is nfsd, or something that nfsd is
> > >> > waiting for, that is calling nfs_release_page(), 100ms is not so l=
ong
> > >> > that throughput will be seriously affected.
> > >> >
> > >> > When fail-over happens a remote (foreign) client will first become
> > >> > disconnected and then turn into a local client.
> > >> > To prevent deadlocks from happening at this point, we still have a
> > >> > timeout when the COMMIT has been sent to a remote client. In this =
case
> > >> > the timeout is longer (1 second).
> > >> >
> > >> > So when a node that has mounted a remote filesystem loses the
> > >> > connection, nfs_release_page() will stop blocking and start failin=
g.
> > >> > Memory allocators will then be able to make progress without block=
ing
> > >> > in NFS.  Any process which writes to a file will still be blocked =
in
> > >> > balance_dirty_pages().
> > >> >
> > >> > This patch makes use of the new 'private' field in
> > >> > "struct wait_bit_key" to store the start time of a commit, so the
> > >> > 'action' function called by __wait_on_bit() knows how much longer
> > >> > it is appropriate to wait.
> > >> >
> > >>
> > >> This puts way too much RPC connection logic in the NFS layer: we rea=
lly
> > >> should not have to care. Is there any reason why we could not just u=
se
> > >> RPC_TASK_SOFTCONN to have the commit fail if the connection is broke=
n?
> > >
> > > I tried to keep as much in the RPC layer as I could....
> > >
> > > There really is a big difference between talking to an 'nfsd' on the =
same
> > > machine and talking to one on a different machine.  In the first case=
 you
> > > need to be cautious of deadlocks, in the second you don't.  That is a
> > > difference that matters to NFS, not to RPC.
> > >
> > > I guess we could always have a timeout, even when connected to a remo=
te
> > > server.  We would just end up blocking somewhere else when the server=
 was not
> > > responding.
> > >
> > > I don't think SOFTCONN is really appropriate.  We don't want the COMM=
IT to
> > > stop being retried.  We just don't want the memory reclaim code to bl=
ock
> > > waiting for the COMMIT.
> > >
> > >>
> > >> Note that all this has to come with a huge WARNING: all your data ma=
y be
> > >> lost even if you think you just fsync()ed it. Is there any difference
> > >> between doing this and using the 'async' export option on the knfsd
> > >> side?
> > >>
> > >
> > > I don't think this patch risks losing data at all - that certainly is=
n't the
> > > intent.
> > > This patch only affects the behaviour of ->releasepage, and only allo=
ws it to
> > > fail instead of block.  It is perfectly acceptable for releasepage to=
 fail
> > > and it doesn't result in data loss.  It just means that the page is b=
usy.
> > >
> >=20
> > So why not just change the behaviour of ->releasepage() to always
> > initiate a non-blocking commit and then wait up to 1 second for the
> > PG_private bit to be released?
> >=20
>=20
> Would that work?
> PG_private seems to be set when the page is being written, not when the
> COMMIT is happening.

Ahh... it is set when the page is written and not cleared until it is
committed.  So yes, we could do it that way if you prefer.

Are you happy with the same timeout whether the the server is local or remo=
te?
The dynamics of the situation are very different, but I guess I don't hit
deadlocks in the local-server case so often that the occasional 1 second
delay would hurt.

I'd need to add a 'wake_up_bit(PG_private, &page->flags)' after
ClearPageBit().

I'll send you a patch early next week.

Thanks,
NeilBrown


--Sig_/kZzLnqPFNVuSz7bVwhsRGLJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/Vhtjnsnt1WYoG5AQLGAhAAvMIpKCWvrr1Cc68NAQEKLf2nhBQLheQF
061jtMPMzjbDDBRs9WM+sIvoIQg/D8JwlGxm9nRcZLByV6CbDc89oSYogPzrfmtp
oo2gUtvZoRRwGaLdqyW0wktXLPht3BbpJog3U1rPxgBCUndNbeJw1BfE2bWKkZ/5
KU8BbVc+0i+XGcXxHQftO28q13DoxjwyExUZMoyV8rYlxBfpgC6U2JBxkwzjwfDu
qeJMUf1wQE8uexOLwt7IZkAM6cCPRg6mfEebwc60LDgyBd1fpmOx3Rcx6El86iwL
ETuW7Y6mrPI2HKqcODtkIMxREExx1Bq5xQoX3af0azHQBdRk/Cr8hlnqjZ/yJY2a
ct7K/HYNCdOS4I7nexD6vXG7ts6VWJA6xGqQFq0XZbiimqrJrOmMZ/hH3e6w+tJw
edrh/T6YAYluJHtTFCK6Xf0bkfVxrjlla6v5G35IHRR5QwYmTv7Kgws+1qp04CTf
VVLl0x2tYQQ9ZJhtRIJt7xMVuI02Fu8IGW514J3FbUAmCLxlI54XQ2BXEOMpyur1
i6WuWlSACd6tbFNa9cSxN98ffQoc/KlUBd1NrLC43Rrn1TyJng+jhaoB0lid3WCB
3g2NkEWnCAn6crtmQt6Kus+43huo4VnIoUxYwNWbj6FRSFRs6tfXSkhiW0Rob16j
BWSsAiGncO8=
=iJWy
-----END PGP SIGNATURE-----

--Sig_/kZzLnqPFNVuSz7bVwhsRGLJ--
