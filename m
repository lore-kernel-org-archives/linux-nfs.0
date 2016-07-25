Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52517 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015AbcGYHWQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jul 2016 03:22:16 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 25 Jul 2016 17:22:09 +1000
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/8] mountd: don't add paths to non-mounted export points to pseudo-root
In-Reply-To: <20160721173350.GD27148@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble> <20160714022643.5874.27117.stgit@noble> <20160718203242.GD12304@fieldses.org> <8760s19qul.fsf@notabene.neil.brown.name> <20160721173350.GD27148@fieldses.org>
Message-ID: <87zip641y6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 22 2016, J. Bruce Fields wrote:

> On Wed, Jul 20, 2016 at 08:59:30AM +1000, NeilBrown wrote:
>> On Tue, Jul 19 2016, J. Bruce Fields wrote:
>>=20
>> > On Thu, Jul 14, 2016 at 12:26:43PM +1000, NeilBrown wrote:
>> >> export points with the "mountpoint" flag should not be exported
>> >> if they aren't mounted.
>> >> They shouldn't even appear in the pseudo-root filesystem.
>> >> So add an appropriate check to v4root_set().
>> >>=20
>> >> This means that the v4root might need to be recomputed whenever a
>> >> filesystem is mounted or unmounted.  So when there are export points
>> >> with the "mountpoint" flag, check for changes in the mount table.
>> >> This is done be measuring the size of /proc/mounts.
>> >
>> > Surely there's some more reliable measurement--could we track some data
>> > about the mountpoint itself, maybe?
>>=20
>> We could.  But it would be more complex code for very little gain.
>> I did consider using select() on /proc/mounts to get a notification
>> whenever anything changes.  What we be more reliable but more difficult.
>> I also considered calculating an SHA1, or maybe just a crc32 on the
>> contents of /proc/mounts.  But then I realised that the size was very
>> easy and very nearly as reliable.
>
> So we don't care enough about the mountpoint option enough to make it
> work 100% reliably?
>
> If we expect too few users for there to be a real chance of hitting the
> bad case here, then I wonder again whether the whole feature is worth
> the trouble.
>
>> > But I'd still like some more justification for this change in logic.
>> > Does anyone currently use the "mp" option?  If not, could we just
>> > deprecate it?  If so, can we really get away with changing it this way?
>>=20
>> I have a customer complaining that it doesn't work as advertised for
>> NFSv4.  So presumably they have a use-case, though I haven't asked for
>> details on exactly why they want it.
>
> I'd be inclined to ask for more details about the use case before
> continuing.

I asked, and found the answer quite helpful.  So thanks for prompting
that.

For NFSv2/3, If I list "/export/foo" in /etc/exports, but /export/foo
fails to mount during boot, then a client which tries to mount
"/export/foo" will get a file handle on /export (probably the root
filesystem).
Unless subtree_check is set (which we don't like) this effectively means
that the whole root filesystem is potentially exported, if the client can
determine the filehandles.
Once the problem is fixed, the filesystem is mounted, and "exportfs -r"
is run (possibly by reboot), the root filesystem will no longer be
exported, so that filehandle that the client has becomes stale (this is
the particlar symptom the customer mentioned).

I think it is safe to argue that having 'mount' fail is safer than
having it succeed, present an empty directory, and then have that
directory suddenly become stale at some later time.

For NFSv4 the root filesystem is always exported, but usually as the
'pseudo-root', being read-only and files being completely unavailable.
If /export/foo is not mounted but /export/foo is exported, then at least
part of the root filesystem will be exported (potentially) r/w.
I'm not sure what happens with filehandles.  A filehandle from the pseudo-r=
oot
filesystem has fsid=3D0.  A filehandle from a properly exported directory
on the root filesystem might not - I'd have to check another day.
So you might not get the 'stale file handles', but would might still get
unexpected access to the root filesystem.

So I think this justifies maintaining (and maybe even encouraging) the
'mountpoint' export option.

For NFSv4 it is probably OK for the to-be-mounted-on directory to be visibl=
e,
but firmly 'pseudo'.  So I can probably drop my elegant /proc/mounts
change detector which you aren't fond of.

When we get a filehandle for a filesystem which isn't currently mounted
the current code sends no response, so clients hang.  My latest patch
sends ESTALE, so client gets an error.
I wonder if we could arrange to make just the exported root look like an
empty (pseudo-root-style) directory.  Then when the filesystem gets
mounted the directory morphs into the real thing..
For files on the filesystem I could probably be convinced either way,
unless testing shows some unpleasant behaviour.

Are you convinced?  At all?

Thanks,
NeilBrown


>
> As it is I'm inclined towards some plan like documenting "mountpoint" as
> deprecated, warning on use, and taking it out eventually.
>
> --b.
>
>> I actually think this is the most useful of the changes.  It means that
>> if a filesystem isn't mounted, it isn't even visible over NFSv4.
>>=20
>> After all, the reality is that people export filesystems, not names in
>> their namespace.  NFSv4 tries to make it all look like the same thing,
>> and there is some justification for that.  But I think a lot of people
>> think about it as filesystems being exported, and the mountpoint option
>> allows that thought to be expressed in the configuration.
>>=20
>> NeilBrown
>>=20
>>=20
>> >
>> > --b.
>> >
>> >>=20
>> >> Signed-off-by: NeilBrown <neilb@suse.com>
>> >> ---
>> >>  support/include/v4root.h |    2 +-
>> >>  utils/mountd/auth.c      |   29 +++++++++++++++++++++++++++--
>> >>  utils/mountd/v4root.c    |   11 ++++++++++-
>> >>  3 files changed, 38 insertions(+), 4 deletions(-)
>> >>=20
>> >> diff --git a/support/include/v4root.h b/support/include/v4root.h
>> >> index 706c15c70d95..406fd4e43e5a 100644
>> >> --- a/support/include/v4root.h
>> >> +++ b/support/include/v4root.h
>> >> @@ -10,6 +10,6 @@
>> >>  #define V4ROOT_H
>> >>=20=20
>> >>  extern int v4root_needed;
>> >> -extern void v4root_set(void);
>> >> +extern void v4root_set(int *mountpoints_checked);
>> >>=20=20
>> >>  #endif /* V4ROOT_H */
>> >> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
>> >> index 0881d9a6edba..5bd7e6622307 100644
>> >> --- a/utils/mountd/auth.c
>> >> +++ b/utils/mountd/auth.c
>> >> @@ -77,6 +77,29 @@ check_useipaddr(void)
>> >>  		cache_flush(1);
>> >>  }
>> >>=20=20
>> >> +static int mountpoints_changed(void)
>> >> +{
>> >> +	static int last_size =3D 0;
>> >> +	int size;
>> >> +	int fd;
>> >> +	char buf[4096];
>> >> +	int n;
>> >> +
>> >> +	fd =3D open("/proc/mounts", O_RDONLY);
>> >> +	if (fd < 0)
>> >> +		/* ignore mountpoint changes if we cannot read /proc/mounts */
>> >> +		return 0;
>> >> +	size =3D 0;
>> >> +	while ((n =3D read(fd, buf, sizeof(buf))) > 0)
>> >> +		size +=3D n;
>> >> +	if (n < 0)
>> >> +		return 0;
>> >> +	if (size =3D=3D last_size)
>> >> +		return 0;
>> >> +	last_size =3D size;
>> >> +	return 1;
>> >> +}
>> >> +
>> >>  unsigned int
>> >>  auth_reload()
>> >>  {
>> >> @@ -84,6 +107,7 @@ auth_reload()
>> >>  	static ino_t		last_inode;
>> >>  	static int		last_fd =3D -1;
>> >>  	static unsigned int	counter;
>> >> +	static int		mountpoints_checked =3D 0;
>> >>  	int			fd;
>> >>=20=20
>> >>  	if ((fd =3D open(_PATH_ETAB, O_RDONLY)) < 0) {
>> >> @@ -91,7 +115,8 @@ auth_reload()
>> >>  	} else if (fstat(fd, &stb) < 0) {
>> >>  		xlog(L_FATAL, "couldn't stat %s", _PATH_ETAB);
>> >>  		close(fd);
>> >> -	} else if (last_fd !=3D -1 && stb.st_ino =3D=3D last_inode) {
>> >> +	} else if (last_fd !=3D -1 && stb.st_ino =3D=3D last_inode &&
>> >> +		   (!mountpoints_checked || !mountpoints_changed())) {
>> >>  		/* We opened the etab file before, and its inode
>> >>  		 * number hasn't changed since then.
>> >>  		 */
>> >> @@ -114,7 +139,7 @@ auth_reload()
>> >>  	memset(&my_client, 0, sizeof(my_client));
>> >>  	xtab_export_read();
>> >>  	check_useipaddr();
>> >> -	v4root_set();
>> >> +	v4root_set(&mountpoints_checked);
>> >>=20=20
>> >>  	++counter;
>> >>=20=20
>> >> diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
>> >> index d52172592823..1a5778f9c7de 100644
>> >> --- a/utils/mountd/v4root.c
>> >> +++ b/utils/mountd/v4root.c
>> >> @@ -183,7 +183,7 @@ static int v4root_add_parents(nfs_export *exp)
>> >>   * looking for components of the v4 mount.
>> >>   */
>> >>  void
>> >> -v4root_set()
>> >> +v4root_set(int *mountpoints_checked)
>> >>  {
>> >>  	nfs_export	*exp;
>> >>  	int	i;
>> >> @@ -193,6 +193,7 @@ v4root_set()
>> >>  	if (!v4root_support())
>> >>  		return;
>> >>=20=20
>> >> +	*mountpoints_checked =3D 0;
>> >>  	for (i =3D 0; i < MCL_MAXTYPES; i++) {
>> >>  		for (exp =3D exportlist[i].p_head; exp; exp =3D exp->m_next) {
>> >>  			if (exp->m_export.e_flags & NFSEXP_V4ROOT)
>> >> @@ -202,6 +203,14 @@ v4root_set()
>> >>  				 */
>> >>  				continue;
>> >>=20=20
>> >> +			if (exp->m_export.e_mountpoint) {
>> >> +				*mountpoints_checked =3D 1;
>> >> +				if (!is_mountpoint(exp->m_export.e_mountpoint[0]?
>> >> +						   exp->m_export.e_mountpoint:
>> >> +						   exp->m_export.e_path))
>> >> +					continue;
>> >> +			}
>> >> +
>> >>  			if (strcmp(exp->m_export.e_path, "/") =3D=3D 0 &&
>> >>  			    !(exp->m_export.e_flags & NFSEXP_FSID)) {
>> >>  				/* Force '/' to be exported as fsid =3D=3D 0*/
>> >>=20
>> >>=20
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXlb4hAAoJEDnsnt1WYoG5VgAQAL/gN+dnpkKPG+TKeGbOdo+F
ooIJSsgqV/J7/gOosox5Ns89/dmINXDqqb+jHhEW1ejs+KLAa/eZuwofVkM9kwCE
eQvzUDdwtUEfG/nFPTYBItMpGY2VuDhImhYY48mjMKryQ+kHFQ70BC3vpc1QJhjt
AneDVWn5c+l6NQ1nVrTaaVpsS6irD8vDlI74zS886fEi03x11Bl4e3KE+vkSmuUT
7BsGvcfSfJEuLPPa3xG+8gXhHGZcevjm/RQhT9OLJK4aE0uHbbLNSCgRhDRmtYTz
UYnLfaO1giunimk/CkzpNhFphpZd/HmWfltKY38WKRu3yn9W0UD8j6Ok0fzqrbOV
g6+NqT8Vl4qdJlNpxeu4bT+jfQ5nK0ZAkNmSAUn8q2o3eyj+zdVdX9bw0oVxloXK
VocNDaGa1Ch/4DAB+kukYGn9hCFF6H3EZz8MUUVtbqcMjEoEJHma6CfWPm5//Afw
utJDWFa0bNFx7C7nbp5SZaGqIsYljKPtd3ui690alncHbzmZtNu+XyRMxcpsQJfH
w67wNpoV0crykimLyr3mGd6Z0nQwVeS1K1u1KmB0P2Qs77Q+asFfKL4B/pLf/IDL
lYPyh3lNT/PxJAReEPmHPAcBvxkHmUfzzwnEVX/5uLkydyEPGw7QEvx8L2G14hpf
oBmyNDi3K4RaMWwE0s47
=PMnU
-----END PGP SIGNATURE-----
--=-=-=--
