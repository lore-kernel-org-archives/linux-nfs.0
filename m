Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46405 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab3GHHaR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 03:30:17 -0400
Date: Mon, 8 Jul 2013 17:30:03 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [patch/rfc] allow exported (and *not* exported) filesystems to
 be unmounted.
Message-ID: <20130708173003.131cd901@notabene.brown>
In-Reply-To: <20130702155059.GD31697@fieldses.org>
References: <20130605130541.5968d5c2@notabene.brown>
	<20130605034115.GD13110@ZenIV.linux.org.uk>
	<20130605161934.59ab6804@notabene.brown>
	<20130605133658.GE24193@fieldses.org>
	<20130606100512.1c701a64@notabene.brown>
	<20130701191238.GD19945@fieldses.org>
	<20130702082413.34dac92e@notabene.brown>
	<20130702155059.GD31697@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/yecVi7wjLK8lz9Jh.wi+dWW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/yecVi7wjLK8lz9Jh.wi+dWW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Jul 2013 11:50:59 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Jul 02, 2013 at 08:24:13AM +1000, NeilBrown wrote:
> > On Mon, 1 Jul 2013 15:12:38 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Thu, Jun 06, 2013 at 10:05:12AM +1000, NeilBrown wrote:
> > > > On Wed, 5 Jun 2013 09:36:58 -0400 "J. Bruce Fields" <bfields@fields=
es.org>
> > > > wrote:
> > > >=20
> > > > > On Wed, Jun 05, 2013 at 04:19:34PM +1000, NeilBrown wrote:
> > > > > > On Wed, 5 Jun 2013 04:41:15 +0100 Al Viro <viro@ZenIV.linux.org=
.uk> wrote:
> > > > > >=20
> > > > > > > On Wed, Jun 05, 2013 at 01:05:41PM +1000, NeilBrown wrote:
> > > > > > > >=20
> > > > > > > > Hi Bruce,
> > > > > > > >  this is a little issue that seems to keep coming up so I t=
hought it might be
> > > > > > > >  time to fix it.
> > > > > > > >=20
> > > > > > > >  As you know, a filesystem that is exported cannot be unmou=
nted as the export
> > > > > > > >  cache holds a reference to it.  Though if it hasn't been a=
ccessed for a
> > > > > > > >  while then it can.
> > > > > > > >=20
> > > > > > > >  As I hadn't realised before sometimes *non* exported files=
ystems can be
> > > > > > > >  pinned to.  A negative entry in the cache can pin a filesy=
stem just as
> > > > > > > >  easily as a positive entry.
> > > > > > > >  An amusing, if somewhat contrived, example is that if you =
export '/' with
> > > > > > > >  crossmnt and:
> > > > > > > >=20
> > > > > > > >     mount localhost:/ /mnt
> > > > > > > >     ls -l /
> > > > > > > >     umount /mnt
> > > > > > > >=20
> > > > > > > >  the umount might fail.  This is because the "ls -l" tried =
to export every
> > > > > > > >  filesystem found mounted in '/'.  The export of "/mnt" fai=
led of course
> > > > > > > >  because you cannot re-export an NFS filesystem.  But it is=
 still in the
> > > > > > > >  cache.
> > > > > > > >  An 'exportfs -f' fixes this, but shouldn't be necessary.
> > > > >=20
> > > > > Yeah, ugh.  As a less contrived example, can the default v4 root =
export
> > > > > lead to arbitrary filesystems being pinned just because a client =
tried
> > > > > to mount the wrong path?
> > > >=20
> > > > I think it can only pin filesystems that are exported, either expli=
citly or
> > > > via a parent being exported with 'crossmnt'.
> > >=20
> > > But see utils/mountd/v4root.c, and:
> > >=20
> > > 	[root@server ~]# exportfs -v
> > > 	/export <world>(rw,...)
> > > 	[root@server ~]# mount /mnt
> > >=20
> > > 		[root@pip4 ~]# mount pip4:/ /mnt/
> > > 		[root@pip4 ~]# ls -l /mnt/
> > > 		total 4
> > > 		drwxrwxrwt 3 root root 4096 Jun  7 10:34 export
> > > 		[root@pip4 ~]#=20
> > >=20
> > > 	[root@server ~]# umount /mnt/
> > > 	umount: /mnt: target is busy.
> > > 	...
> > > 	[root@server ~]# grep /mnt /proc/net/rpc/nfsd.export/content=20
> > > 	# /mnt	*()
> >=20
> > You make a good point.  I didn't think that would happen, and I think I=
 could
> > argue that it is a bug.
>=20
> Definitely looks like a bug to me.
>=20
> > I have no idea how easy it would be to "fix" without
> > pouring over the code for a while though.  Or whether it is worth "fixi=
ng".
>=20
> As long as clients are mostly just LOOKUPing down to the export they
> care about people may not hit this too much, but no doubt somebody will
> hit this eventually.
>=20
> > > > > Could the export cache be indexed on a path string instead of a s=
truct
> > > > > path?
> > > >=20
> > > > Yes.  It would mean lots of extra pathname lookups and possibly lot=
s of
> > > > "d_path()" calls.
> > >=20
> > > Right.  Ugh.  Still, struct path seems wrong as it's not something gs=
sd
> > > knows about, and there's not really a 1-1 mapping between the two (see
> > > e.g. the recent complaint about the case where the struct path
> > > represents a lazy-unmounted export
> > > http://mid.gmane.org/<20130625191008.GA20277@us.ibm.com> ).
> >=20
> > I noticed that but haven't really followed it (though I just checked and
> > there isn't much to follow...)
> >=20
> > What do we *want* to happen in this case?  I would argue that when the
> > filesystem is detached the export should immediately become invalid.
> >=20
> > We could possibly put a check in exp_find_key() to see if ek->ek_path
> > was still attached (not sure how to do that) and if it is: invalidate t=
he ek
> > before calling cache_check().  If the "is path detach" test is cheap, we
> > should probably do this.
> >=20
> > Or - we could flush relevant entries from the cache whenever there is a
> > change in the mount table.  That is certainly the preferred option if t=
he "is
> > path detached" test is at all expensive.  But it seems it isn't complet=
ely
> > clear how that flushing should be triggered...
>=20
> There are probably other ways to get this kind of hang too: mounting
> over an export? mount --move?

I could argue that "mount --move" should  trigger a flush just like umount
does.  Mounting over an export (or mounting over a parent of an export) is
not so easy.

The core problem which causes the hang is that the path requested by
svc_export_request cannot be used to refer to the exp->ex_path.
This is something that svc_export_request could check.
e.g. after "d_path", it could "kern_path(pth, 0, &old_path);" and if that
fails or old_path doesn't match ex_path, then somehow invalidate the cache
entry....  though that is a bit awkward. We really want to catch the problem
at exp_find_key time.  Doing it there would be more of a performance burden.

Can d_path tell us that the path isn't reachable?
I think __d_path can, but that isn't exported (yet).  Using that could avoid
the "kern_path()" call.

So I'm thinking:

 - in svc_export_request() use __d_path (which needs to be exported)
 - if that fails, set a new CACHE_STALE flag on the cache_head
 - cache_read notices CACHE_STALE and calls cache_fresh_unlocked() (I think)
   to remove it from the queue.
 - cache_is_valid treats CACHE_STALE like CACHE_NEGATIVE only -ESTALE is
   returned
 - if exp_find() gets -ESTALE from exp_get_by_name, it sets CACHE_STALE on
   'ek'.

It gets a bit complicated doesn't it?

An alternative is that if rpc.mountd gets a request for a path that doesn't
exist, or that when it responds to a request, the request remains in the
channel, then it simply flushes everything.

This is a bit heavy handed, but it is a rare occurrence so maybe that doesn=
't
matter.

It doesn't solve my desire for umount of exported filesystems to "just work"
though.

NeilBrown


 -=20

--Sig_/yecVi7wjLK8lz9Jh.wi+dWW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdpqeznsnt1WYoG5AQIifg/9Gmi5bD0ns6zrCP2IWhzk2Chw6OpWwYzL
swgzDjZc5GUzC/U/hZucJzt3TAEQqK0levyhImZg1ml0Nr42t/xMDK8OHdgT5S6b
mdpJcfb5LlQ4zD5uNqVA90CoJFORJqXs27S1Jk4Dx7MDczsz0lS1iZivHmnC4Ru3
sWHMkGVFo8vcATgtwgrfAtcq2n2J7HReaoN8l4LNKNK+U+7XK86ykv/C3eexYyoZ
Z5zcLviMG1Sz8FtXXeWDgev8IwUZEN1uahlOgEICvOQau9lyA64tNwLgyNXxxQXT
f5AUPUswYdxd0lrfIpSFbpzswi3wPrOsveTCyKu9/lpn38gx8MdpoiMvzDqnbb1f
ctp+s90rewMPADPp97YihPo9llmgfFDEktfpY3y8ugdodswiX9pMnJC1jfbXWmV4
3lpjbkcmsssiLZz0DF5k4i5gBl39vR8LCVh7j+pDdIs+TVqWbpoI9esDnwjISR6e
0H1lXVTOskmlHlkeDBAgNm0aSVdVPW4ZxUEA27arLbPaVaWMKgnRzIo4rjhgV7EH
hesE0H69zKfsLkr2egQyH81DsOJT9MPyiyZihrrpIC8Fp8MTrJz8ipBv6dkimotx
OyQmGfu/XaDy/NDqPiygiso+hyO6VJZWbcmBq7wyF1+UJ7f92DSJK47nkew0pGC+
O+0fVOnrtJY=
=yRuD
-----END PGP SIGNATURE-----

--Sig_/yecVi7wjLK8lz9Jh.wi+dWW--
