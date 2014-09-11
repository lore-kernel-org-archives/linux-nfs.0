Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59922 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbaIKKxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 06:53:17 -0400
Date: Thu, 11 Sep 2014 20:53:05 +1000
From: NeilBrown <neilb@suse.de>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Junxiao Bi <junxiao.bi@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] SUNRPC: Fix memory reclaim deadlocks in rpciod
Message-ID: <20140911205305.578bc017@notabene.brown>
In-Reply-To: <20140911085046.GC22042@dhcp22.suse.cz>
References: <CAHQdGtRMFuH9MsJBj5YsOrJW+qFLFp_-X=b_gZPVmgVQ22swqQ@mail.gmail.com>
	<20140826132624.GU17696@novell.com>
	<20140826231938.GA13889@cmpxchg.org>
	<CAHQdGtRPsVFVfph5OcsZk_+WYPPJ-MpE2myZfXAb3jq6fuM4zw@mail.gmail.com>
	<CAHQdGtQPMJNzSM5Wt4RnNqEawBLqmYHycXTmBHhmAt26dz5wCw@mail.gmail.com>
	<20140827153644.GF12374@novell.com>
	<20140904135427.GA14548@dhcp22.suse.cz>
	<20140909123346.434f0443@notabene.brown>
	<20140910134842.GG25219@dhcp22.suse.cz>
	<20140911095743.1ed87519@notabene.brown>
	<20140911085046.GC22042@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/US23JRyD_3m.y0tzv6hZueC"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/US23JRyD_3m.y0tzv6hZueC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 11 Sep 2014 10:50:47 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 11-09-14 09:57:43, Neil Brown wrote:
> > On Wed, 10 Sep 2014 15:48:43 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> >=20
> > > On Tue 09-09-14 12:33:46, Neil Brown wrote:
> > > > On Thu, 4 Sep 2014 15:54:27 +0200 Michal Hocko <mhocko@suse.cz> wro=
te:
> > > >=20
> > > > > [Sorry for jumping in so late - I've been busy last days]
> > > > >=20
> > > > > On Wed 27-08-14 16:36:44, Mel Gorman wrote:
> > > > > > On Tue, Aug 26, 2014 at 08:00:20PM -0400, Trond Myklebust wrote:
> > > > > > > On Tue, Aug 26, 2014 at 7:51 PM, Trond Myklebust
> > > > > > > <trond.myklebust@primarydata.com> wrote:
> > > > > > > > On Tue, Aug 26, 2014 at 7:19 PM, Johannes Weiner <hannes@cm=
pxchg.org> wrote:
> > > > > [...]
> > > > > > > >> wait_on_page_writeback() is a hammer, and we need to be be=
tter about
> > > > > > > >> this once we have per-memcg dirty writeback and throttling=
, but I
> > > > > > > >> think that really misses the point.  Even if memcg writeba=
ck waiting
> > > > > > > >> were smarter, any length of time spent waiting for yoursel=
f to make
> > > > > > > >> progress is absurd.  We just shouldn't be solving deadlock=
 scenarios
> > > > > > > >> through arbitrary timeouts on one side.  If you can't wait=
 for IO to
> > > > > > > >> finish, you shouldn't be passing __GFP_IO.
> > > > >=20
> > > > > Exactly!
> > > >=20
> > > > This is overly simplistic.
> > > > The code that cannot wait may be further up the call chain and not =
in a
> > > > position to avoid passing __GFP_IO.
> > > > In many case it isn't that "you can't wait for IO" in general, but =
that you
> > > > cannot wait for one specific IO request.
> > >=20
> > > Could you be more specific, please? Why would a particular IO make any
> > > difference to general IO from the same path? My understanding was that
> > > once the page is marked PG_writeback then it is about to be written to
> > > its destination and if there is any need for memory allocation it sho=
uld
> > > better not allow IO from reclaim.
> >=20
> > The more complex the filesystem, the harder it is to "not allow IO from
> > reclaim".
> > For NFS (which started this thread) there might be a need to open a new
> > connection - so allocating in the networking code would all need to be
> > careful.
>=20
> memalloc_noio_{save,restor} might help in that regards.

It might.  It is a bit of a heavy stick though.
Especially as "nofs" is what is really wanted (I think).

>=20
> > And it isn't impossible that a 'gss' credential needs to be re-negotiat=
ed,
> > and that might even need user-space interaction (not sure of details).
>=20
> OK, so if I understand you correctly all those allocations tmight happen
> _after_ the page has been marked PG_writeback. This would be bad indeed
> if such a path could appear in the memcg limit reclaim. The outcome of
> the previous discussion was that this doesn't happen in practice for
> nfs code, though, because the real flushing doesn't happen from a user
> context. The issue was reported for an old kernel where the flushing
> happened from the user context. It would be a huge problem to have a
> flusher within a restricted environment not only because of this path.
>=20
> > What you say certainly used to be the case, and very often still is.  B=
ut it
> > doesn't really scale with complexity of filesystems.
> >=20
> > I don't think there is (yet) any need to optimised for allocations that=
 don't
> > disallow IO happening in the writeout path.  But I do think waiting
> > indefinitely for a particular IO is unjustifiable.
>=20
> Well, as Johannes already pointed out. The right way to fix memcg
> reclaim is to implement proper memcg aware dirty pages throttling and
> flushing. This is a song of distant future I am afraid. Until then we
> have to live with workarounds. I would be happy to make this one more
> robust but timeout based solutions just sound too fragile and triggering
> OOM is a big risk.
>=20
> Maybe we can disbale waiting if current->flags & PF_LESS_THROTTLE. I
> would be even tempted to WARN_ON(current->flags & PF_LESS_THROTTLE) in
> that path to catch a potential misconfiguration when the flusher is a
> part of restricted environment. The only real user of the flag is nfsd
> though and it runs from a kernel thread so this wouldn't help much to
> catch potentialy buggy code. So I am not really sure how much of an
> improvement this would be.
>=20

I think it would be inappropriate to use PF_LESS_THROTTLE.  That is really
about throttling the dirtying of pages, not their writeback.

As has been said, there isn't really a bug that needs fixing at present, so
delving too deeply into designing a solution is probably pointless.

Using global flags is sometimes suitable, but it doesn't help when you are
waiting for memory allocation to happen in another process.
Using timeouts is sometimes suitable, but only if the backup plan isn't too
drastic.

My feeling is that the "ideal" would be to wait until:
  - this thread can make forward progress, or
  - no thread (in this memcg?) can make forward progress
In the first case we succeed.  In the second we take the most gentle backup
solution (e.g. use the last dregs of memory, or trigger OOM).
Detecting when no other thread can make forward progress is probably not
trivial, but it doesn't need to be cheap.

Hopefully when a real issue arises we'll be able to figure something out.

Thanks,
NeilBrown

--Sig_/US23JRyD_3m.y0tzv6hZueC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBF/ETnsnt1WYoG5AQJ1CRAAp7mHh3xV36yHbaA/xbV8Vl5HaTierQuu
I9jP1D7pS0ahVvnYQI5y0F1yX+4lKazt6zwNl8Xgff8rMcdsVnplVym8hvOp4VEC
MudmGBzzgH+jrhtl+IFylmLmBtdGfk0ircMpD5IOwA6hsuo6ATYUqgP92oO/nlY1
Qwh5j6+B0HBbclNpYmgnzifh/RHd811WwC2ZJSclaP8EAYhMHGSVeqhpVXMnFdKj
pfycf9q7fm9o6JHw6ReLHP5e7U8yQeiUOVC0BHzujFph2V4wnpoHpRHe6FeTBMFm
bUkYmzGm+Gu5sTXhoVlefpAyXKeM1yQi0wsHXiEEcIC8DQc+BoBT4SlDEj7ss893
n/P0TRxT0DbsH3lYu5z+6kGYUfv8piu15T6/ci/YLXjAI+ywxjNJUThzgeI9S96J
yRhewFA2PAFn64Bme0DyhJe3L7vn0upLmZo8TUD2KI/yfR8j3+gvuIJN5HMSaJDK
52qJFZtrM4K28B9BQ+7OuR41ij82beklv4GGqXL48qO16zd1GlBvTvtvn9ktPyvo
Mcnp6JoryAAxaoSrNqPryhPblY8PmF54O4/NJenh6rd85DXgAnSfc+ZFiWpBo/78
qtPzyTG2U2yIVwqlTp0uqkqqgl/mA7RMl9htbnbQAPqW0Z657ad2Loz25z+5K5kD
0H8mbGfDYxI=
=LAHm
-----END PGP SIGNATURE-----

--Sig_/US23JRyD_3m.y0tzv6hZueC--
