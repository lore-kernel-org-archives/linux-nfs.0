Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49637 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab2JIAas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 20:30:48 -0400
Date: Tue, 9 Oct 2012 11:30:54 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121009113054.610c8675@notabene.brown>
In-Reply-To: <5072BC2A.1060100@RedHat.com>
References: <20120918112329.7d88ed9e@notabene.brown>
	<20121001154309.GD18400@fieldses.org>
	<20121002123810.15bd1ee2@notabene.brown>
	<20121002143334.GA1435@fieldses.org>
	<20121003134629.72557522@notabene.brown>
	<20121003151349.GD14313@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
	<20121003162728.GE14313@fieldses.org>
	<20121004084659.38632320@notabene.brown>
	<20121004160739.GA4693@fieldses.org>
	<20121008170304.37dc6ae9@notabene.brown>
	<5072BC2A.1060100@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZevjVlOXQ45li81Ez03orvr"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZevjVlOXQ45li81Ez03orvr
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 08 Oct 2012 07:42:34 -0400 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 08/10/12 02:03, NeilBrown wrote:
> > On Thu, 4 Oct 2012 12:07:39 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> >> On Thu, Oct 04, 2012 at 08:46:59AM +1000, NeilBrown wrote:
> >>> On Wed, 3 Oct 2012 12:27:28 -0400 "J. Bruce Fields" <bfields@fieldses=
.org>
> >>> wrote:
> >>>
> >>>> On Wed, Oct 03, 2012 at 03:48:43PM +0000, Myklebust, Trond wrote:
> >>>>> On Wed, 2012-10-03 at 11:13 -0400, J. Bruce Fields wrote:
> >>>>>> On Wed, Oct 03, 2012 at 01:46:29PM +1000, NeilBrown wrote:
> >>>>>>> On Tue, 2 Oct 2012 10:33:34 -0400 "J. Bruce Fields" <bfields@fiel=
dses.org>
> >>>>>>> wrote:
> >>>>>>>
> >>>>>>>> I guess you're right.  So it starts to sound more like: "you hav=
e a
> >>>>>>>> confusing setup.  Your export configuration says one thing, and =
your
> >>>>>>>> filesystem permissions say another.  Under NFSv3 the confusion d=
idn't
> >>>>>>>> matter, but now it does--time to fix it."
> >>>>>>>>
> >>>>>>>
> >>>>>>> That's the best I could come to - I'm glad to have it confirmed. =
 Thanks!
> >>>>>>>
> >>>>>>> It is unfortunate that Linux NFS uses an anon credential to mount=
 when krb5
> >>>>>>> is in use, and uses 'root' when auth_sys is used (which might be =
anon if
> >>>>>>> "root_squash" is active, but might not).
> >>>>>>> I wonder if it would work to use auth_none for the mount-time loo=
kup, just
> >>>>>>> for consistency..
> >>>>>>>
> >>>>>>> Is the following appropriate?  Is there somewhere better to put t=
his caveat?
> >>>>>>
> >>>>>> Unfortunately, it's more complicated than this, as it depends on c=
lient
> >>>>>> implementation and configuration details.
> >>>>>>
> >>>>>> Something like this would be more accurate but possibly too long:
> >>>>>>
> >>>>>> 	Note that under NFSv2 and NFSv3, the mount path is traversed by
> >>>>>> 	mountd acting as root, but under NFSv4 the mount path is looked
> >>>>>> 	up using the client's credentials.  This means that, for
> >>>>>> 	example, if a client mounts using a krb5 credential that the
> >>>>>> 	server maps to an "anonmyous" user, then the mount will only
> >>>>>> 	succeed if that directory and all its parents allow eXecute
> >>>>>> 	permissions.
> >>>>>
> >>>>> So you're listing this as a "feature" rather than a bug? There shou=
ld be
> >>>>> no reason to constrain the pseudofs to use the permission checks fr=
om
> >>>>> the underlying filesystem.
> >>>>
> >>>> I'd be fine with that.
> >>>>
> >>>> (That still leaves some subtle v3/v4 difference in the case of mount
> >>>> paths underneath an export?
> >>>>
> >>>> What *is* the existing mountd behavior there, exactly?  I'm inclined=
 to
> >>>> think allowing mounts of arbitrary subdirectories is a bug, but maybe
> >>>> there's some historical reason for it or maybe someone already depen=
ds
> >>>> on it.)
> >>>>
> >>>> --b.
> >>>
> >>> The behaviour is simple that you mount a filehandle (typically belong=
ing to a
> >>> directory) and that filehandle can be anything inside any exported fi=
lesystem.
> >>
> >> It's not the nfsd behavior that bothers me--there's nothing we can do
> >> about the fact that access by filehandle can bypass directory
> >> permissions.
> >>
> >> What bothers is that mountd will apparently allow anyone to do a lookup
> >> anywhere in an exported filesystem.
> >=20
> > Not anyone - it requires a privileged source port from a known host.
> > So it is only "anyone who can get 'root'".
> >=20
> >>
> >> I don't know--maybe I shouldn't be so concerned about the possibility a
> >> rogue user could figure out that my "Music" directory includes an
> >> unreasonable number of Miles Davis titles.
> >>
> >>> Yes, please do depend on being able to mount filehandles that aren't =
to root
> >>> of a filesystem.
> >>>
> >>> The case the brought this issue to my attention involved the server h=
aving
> >>> a directory containing hundreds of home directories.  This directory =
is
> >>> exported.
> >>>
> >>> If they mount that top level directory they get horrible performance.=
  If
> >>> they use an automounter to just mount the homes that are accessed it =
works
> >>> better.  They weren't able to explain why but my guess is that some t=
ools
> >>> (GUI filesystem browser) would occasionally do the equivalent of "ls =
 -l" of
> >>> the top level directory which would hammer nfs-idmapd and probably ld=
ap....
> >>> though you would think that would get cached and not be a problem for=
 long.
> >>> So maybe it is more subtle than that.
> >>
> >> Getting all the id->name mappings for a 100-entry directory is going to
> >> require a 100 serialized upcalls to idmapd (and then possibly ldap), a=
nd
> >> by default it looks like the idmapd cache will go cold after 10
> >> minutes....  Not hard to imagine that could be a problem.
> >>
> >> Running multiple idmapd process would be easy and might help?  Though
> >> not if the client's just giving us the getattrs one at a time.
> >>
> >> Or maybe the problem's somewhere else entirely, but that's a real bug =
if
> >> we aren't giving good performance on /home.
> >=20
> > I did some experimenting..
> > On both 'client' and 'server':
> >   for i in `seq 2000 3000`; do echo u$i:x:$i:1000::/nohome:/bin/false; =
done
> >>> /etc/passwd
> >=20
> > On server in suitable directory
> >=20
> >   for i in `seq 2000 3000`; do mkdir $i ; chown u$i $i ; done
> >=20
> > Mount that directory onto the client with NFSv3 and "time ls -l" takes a
> > little under 4 seconds.
> > Mount with NFSv4 and it takes about the same.  However:
> >=20
> > .....
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2974
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2975
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2976
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2977
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2978
> > drwxr-xr-x 2 u2979      root 4096 Oct  8 16:19 2979
> > drwxr-xr-x 2 u2980      root 4096 Oct  8 16:19 2980
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2981
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2982
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2983
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2984
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2985
> > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2986
> > ....
> >=20
> >=20
> > tcpdump shows the server is returning the write stuff, but something if=
 going
> > wrong on the client.  I've tried unmounting/remounting and killing/rest=
arting
> > rpc.idmapd.
> > I had some config problems previously .. is there any chance that these
> > unknown entries are in a cache?  Any easy way to view or flush the cach=
e?
> Assuming you are using the keyring based idmapper, "nfsidmap -cv" will
> clear the keyring of user and group ids. See nfsidmap(5).

Thanks... though I'm running some ancient system which only has nfs-utils
1.2.5 and so "nfsidmap -cv" returns silently, but does nothing.
That's OK, I have source -- build, copy, test...

# /tmp/nfsidmap -cv
nfsidmap: fopen(/proc/keys) failed: No such file or directory


Hmm, not what I was expecting ... grep grep ahhh:

config KEYS_DEBUG_PROC_KEYS
        bool "Enable the /proc/keys file by which keys may be viewed"

# zcat /proc/config.gz | grep KEYS_DEBUG_PROC
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set


That explains it then - we need a debug option set or we cannot flush the
idmap cache.  I guess flushing a cache is a debugging operation, but its a
bit surprising.  And in my case: annoying.

Would you expect distros to enable CONFIG_KEYS_DEBUG_PROC_KEYS?  If so I'll
get it enabled for SUSE (it is enabled in the 'debug' kernel, but not
'desktop' or 'default).  If not, the man page maybe should safe that -c and
-r require a kernel with debugging enabled.

But I set up another machine as the client and configured it properly before
testing, and everything works fine and reasonably fast.  So my guess that
id lookup for thousands of different ids caused slowness was probably wrong.


Thanks,
NeilBrown

--Sig_/ZevjVlOXQ45li81Ez03orvr
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUHNwPjnsnt1WYoG5AQKb4Q//VRJAX8TqOQfXAbLLeTkUGB6Ci4K+yf0e
gIfg9Zb8vZr6gNLOF8eHbV7ghEA1QMrEd7SjyxonBx+i2nehRKB7Al6HdGgAwQWr
JhDPK4EBzST6ydOsaquCkl0i2MGFTYjmy0Y5FJq9buE6yoBQp1Kr89+CRMue4zub
e2A3ssmCw5twwrHTCu71aTJZdUeq9m7LFHFJgLUDSyOAZeLwaRcBjH9kkwZxVDqs
SXT5/NwQl593pBdlY1EolA1JVLLKpzcBInc4+VVwD2dvqynfVc2ynMzJ9DZiuaPP
3NiqEeTWPYLvDUUX3noClAbIDZHORpJXplgBey4jBV9Y/LVsEkalFOi0qd3/6V7a
/NkdxBtZ/p/SVSMGfYyYVJreDigGTXHyFbNspJ7nkKl42lM5ZnMURWhtpsF2JfX9
zV+W+JsNGHkCdgYI8TPfN1THdhkW+wPdvm1BftxSly/353PTIkQuLPFfI1xytGqO
NpGhWVjzzaA+iFX5w8zha0AmP7aW6MGNilelgq9kPOrcpQMtd2cFeRpconW3RbGy
jlhD4Pujw2d4/Pc1ViaZupL7G34wdZB4tc/hOxZ2XqA4b+Qum6m8P6GRjQlAdjhn
1RHYfeiKLry3vkwLOvE/7W4HTchM1qWDvXv6XTXx5PYi1zB/BhyRuy0nS0GwhRMG
gmZtXnDqhos=
=dfQx
-----END PGP SIGNATURE-----

--Sig_/ZevjVlOXQ45li81Ez03orvr--
