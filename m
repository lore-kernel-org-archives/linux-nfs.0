Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52476 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109AbaIJX5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Sep 2014 19:57:55 -0400
Date: Thu, 11 Sep 2014 09:57:43 +1000
From: NeilBrown <neilb@suse.de>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140911095743.1ed87519@notabene.brown>
In-Reply-To: <20140910134842.GG25219@dhcp22.suse.cz>
References: <20140825164852.50723141@notabene.brown>
	<20140826105304.GT17696@novell.com>
	<CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
	<20140826132624.GU17696@novell.com>
	<20140826231938.GA13889@cmpxchg.org>
	<CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
	<CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
	<20140827153644.GF12374@novell.com>
	<20140904135427.GA14548@dhcp22.suse.cz>
	<20140909123346.434f0443@notabene.brown>
	<20140910134842.GG25219@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/3rkqSz4FoZ6s=BZMMkDRh6O"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3rkqSz4FoZ6s=BZMMkDRh6O
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 10 Sep 2014 15:48:43 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-09-14 12:33:46, Neil Brown wrote:
> > On Thu, 4 Sep 2014 15:54:27 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> >=20
> > > [Sorry for jumping in so late - I've been busy last days]
> > >=20
> > > On Wed 27-08-14 16:36:44, Mel Gorman wrote:
> > > > On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
> > > > > On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
> > > > > <trond.myklebust@primarydata.com> wrote:
> > > > > > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cmpxch=
g.org> wrote:
> > > [...]
> > > > > >> wait_on_page_writeback() is a hammer, and we need to be better=
 about
> > > > > >> this once we have per-memcg dirty writeback and throttling, bu=
t I
> > > > > >> think that really misses the point.  Even if memcg writeback w=
aiting
> > > > > >> were smarter, any length of time spent waiting for yourself to=
 make
> > > > > >> progress is absurd.  We just shouldn't be solving deadlock sce=
narios
> > > > > >> through arbitrary timeouts on one side.  If you can't wait for=
 IO to
> > > > > >> finish, you shouldn't be passing __GFP_IO.
> > >=20
> > > Exactly!
> >=20
> > This is overly simplistic.
> > The code that cannot wait may be further up the call chain and not in a
> > position to avoid passing __GFP_IO.
> > In many case it isn't that "you can't wait for IO" in general, but that=
 you
> > cannot wait for one specific IO request.
>=20
> Could you be more specific, please? Why would a particular IO make any
> difference to general IO from the same path? My understanding was that
> once the page is marked PG_writeback then it is about to be written to
> its destination and if there is any need for memory allocation it should
> better not allow IO from reclaim.

The more complex the filesystem, the harder it is to "not allow IO from
reclaim".
For NFS (which started this thread) there might be a need to open a new
connection - so allocating in the networking code would all need to be
careful.
And it isn't impossible that a 'gss' credential needs to be re-negotiated,
and that might even need user-space interaction (not sure of details).

What you say certainly used to be the case, and very often still is.  But it
doesn't really scale with complexity of filesystems.

I don't think there is (yet) any need to optimised for allocations that don=
't
disallow IO happening in the writeout path.  But I do think waiting
indefinitely for a particular IO is unjustifiable.

>=20
> > wait_on_page_writeback() waits for a specific IO and so is dangerous.
> > congestion_wait() or similar waits for IO in general and so is much saf=
er.
>=20
> congestion_wait was actually not sufficient to prevent from OOM with
> heavy writer in a small memcg. We simply do not know how long will the
> IO last so any "wait for a random timeout" will end up causing some
> troubles.

I certainly accept that "congestion_wait" isn't a sufficient solution.
The thing I like about it is that it combines a timeout with a measure of
activity.
As long as writebacks are completing, it is reasonable to
wait_on_page_writeback().  But if no writebacks have completed for a while,
then it seems pointless waiting on this page any more.  Best to try to make
forward progress with whatever memory you can find.

NeilBrown

--Sig_/3rkqSz4FoZ6s=BZMMkDRh6O
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBDldznsnt1WYoG5AQJ1yBAAi/bqgwRk8XkT5lBr+BjfvGTATVdkoMBl
pS2hWIA/90Aym4Q63tIW1ZYPSCPs7MvrQx3eVFh1soHTzEWZILd6m02ihb1f3RMI
AhSFbj1NmGUAYrmyW0llgPWTbxDENreZloswsuhtB43jv+d49WyGDC5YpSkPFPNI
4TJVKHwnw4fe+BOOVLzwrj5wm3C9JbGWmWqgYVlndmvGh2EeEbYfFhmUsWf4/9Iu
9kPMJ9GK0f3KDbZHN/LHSxmftgHjDmDufCrmwR4278Wk9AccS/s40o4+ob71dMyw
1gzqf5ts652Dw3CbhhfzZUkqOOk+uPwDkklC3dtZ2H8qwp2io4T6lZ5xAO//3OnQ
hdw96o2zAvkiVopn0ClA7N8TUejgrxgNgFC1tZzzO7uIasE7TvdNVBIGpAXJKoJw
G4aIBNFA+6kduFi0SBMY3IcfseMaP67AlUF5mL1+ng8dBrU6K2m2M3pdujUDHz5g
jB96757hGNJVtUXQy64ZcXefJb2e4sr4kZ4gZmv/5yMdvyEVFge3Bcqizc4CxaDB
B9wm6CXuZ39ktORe1qqBF430MihCyaGUt4EpXfmxhPdlqIbTFWdwXsyOBZ+/CJt/
EM7JZFQKcHsKTEmOGssToM9nnXO2nQlqFhhGa0af0PhxAGCA5GIc/dS333xHf8tW
IP5J7GHkGwM=
=ZKBC
-----END PGP SIGNATURE-----

--Sig_/3rkqSz4FoZ6s=BZMMkDRh6O--
