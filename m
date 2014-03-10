Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41452 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487AbaCJWBe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 18:01:34 -0400
Date: Tue, 11 Mar 2014 09:01:24 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - v2] mount.nfs: Fix fallback from tcp to udp
Message-ID: <20140311090124.05409b1b@notabene.brown>
In-Reply-To: <531E2E3F.2020805@RedHat.com>
References: <20140224142349.784345f9@notabene.brown>
	<531E2E3F.2020805@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/SJzNSggD=I0z68K2qibJg9N"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/SJzNSggD=I0z68K2qibJg9N
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Mar 2014 17:27:27 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> Hey Neil,
>=20
> On 02/23/2014 10:23 PM, NeilBrown wrote:
> >=20
> > Protocol negotiation in mount.nfs does not correctly negotiate with a
> > server which only supports NFSv3 and UDP.
> >=20
> > When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
> > it does not fall back to NFSv3, as this is not recognised as a
> > "does not support NFSv4" error.
> > However ECONNREFUSED is a clear indication that the server doesn't
> > support TCP, and ipso facto does not support NFSv4.
> > So ECONNREFUSED should trigger a fallback from v4 to v2/3.
> What server are you running this against?

Not sure, either Linux 3.2 or 3.11.
I don't know exactly what server the bug was reported to me against, I'm
guessing some NAS thing.

https://bugzilla.novell.com/show_bug.cgi?id=3D863749

>=20
> I've started an number of different servers with the "-T -N 4"
> rpc.nfsd flags here is what I've found:
>=20
> When I doing the mount without "-o v3" mount option, the mount
> hangs (forever) in the server discovering trunking code.=20
>=20
> Mount older server like RHEL5 or RHEL6 the mount (w/out the patch)
> success because RPC: Program not registered is return which causes
> the fallback to happen
>=20
> So I'm assuming you are using a recent Linux server because=20
> I do see the ECONNREFUSED with that server, but because I
> have to use the -o v3 this patch does not seem to help.=20
> Basically I spin in this loop:
>=20
> mount.nfs: prog 100003, trying vers=3D3, prot=3D6
> mount.nfs: trying 127.0.0.1 prog 100003 vers 3 prot TCP port 2049
> mount.nfs: portmap query failed: RPC: Remote system error - Connection re=
fused
>=20
> I have not debug as to what is going on, but it does not look like
> the patch is doing what is expect...=20
>=20
> steved.

With  a 3.11.10 client talking to a 3.2.0 server I run
  rpc.nfsd 0
  rpc.nfsd -T -N4
on the server, then
  rpcinfo -p SERVER | grep nfs
shows
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl

On client I run
    mount -v SERVER:/PATH /mnt
and I get
mount.nfs: trying text-based options 'vers=3D4,addr=3D192.168.1.3,clientadd=
r=3D192.168.1.2'
mount.nfs: mount(2): Connection refused

repeating ever 10 seconds or so.  It eventually times out after 2 minutes.

Same client to a 3.10 server I get the same behaviour.
3.2.0 client and 3.10 server, same behaviour again.

I have noticed that sometimes when I stop the NFS server the registration
with rpcbind doesn't go away.  Not often, but sometimes.  I wonder if that
could be confusing something?  Can you check that nfsv4 has been
de-registered from rpcbind?

I note you are getting the error:

> mount.nfs: portmap query failed: RPC: Remote system error - Connection re=
fused

This seems to suggest that rpcbind isn't running.  Yet when I kill rpcbind
and try a v3 mount I get

  mount.nfs: portmap query failed: RPC: Unable to receive - Connection refu=
sed

which is slightly different, so presumably there is a different cause in yo=
ur
case.

Maybe you could turn on some rpcdebug tracing to see what is happening?

Thanks,
NeilBrown

>=20
> >=20
> > However ECONNREFUSED may simply indicate that NFSv4 isn't supported
> > *yet*.  i.e. the server is still booting and isn't responding to NFS
> > requests yet.  So if we subsequently find that NFSv3 is supported, we
> > need to check with rpcbind to confirm that NFSv4 really isn't
> > supported.
> > If rpcbind reports that v4 is not supported after reporting that v3
> > is, we can safely use v4.  If it reports that v4 is supported, we need
> > to retry v4.
> >=20
> > One line in this patch requires explanation.  It is
> > +		save_pmap.pm_vers =3D 4;
> >=20
> > This is needed as nfs_probe_nfsport is entered with pm_vers already
> > set, by the line
> > 		nfs_pmap->pm_vers =3D mntvers_to_nfs(*probe_vers);
> > in nfs_probe_bothports().  This makes the passing of probe_nfs3_only
> > and probe_nfs2_only to nfs_probe_port() in nfs_probe_nfsport()
> > pointless, and the passing of probe_nfs4_only in the new code
> > ineffectual, without resetting pm_vers.
> >=20
> > The setting of pm_vers to mntvers_to_nfs() should probably be removed,
> > but as we don't have any regression tests, doing this would be unwise.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > Reported-by: Carsten Ziepke <kieltux@gmail.com>
> >=20
> > diff --git a/utils/mount/network.c b/utils/mount/network.c
> > index 2fdd2c051be7..0521d5f6709f 100644
> > --- a/utils/mount/network.c
> > +++ b/utils/mount/network.c
> > @@ -149,6 +149,11 @@ static const unsigned int probe_tcp_first[] =3D {
> >  	0,
> >  };
> > =20
> > +static const unsigned int probe_tcp_only[] =3D {
> > +	IPPROTO_TCP,
> > +	0,
> > +};
> > +
> >  static const unsigned long probe_nfs2_only[] =3D {
> >  	2,
> >  	0,
> > @@ -159,6 +164,11 @@ static const unsigned long probe_nfs3_only[] =3D {
> >  	0,
> >  };
> > =20
> > +static const unsigned long probe_nfs4_only[] =3D {
> > +	4,
> > +	0,
> > +};
> > +
> >  static const unsigned long probe_mnt1_first[] =3D {
> >  	1,
> >  	2,
> > @@ -611,18 +621,34 @@ out_ok:
> >   * returned; rpccreateerr.cf_stat is set to reflect the nature of the =
error.
> >   */
> >  static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen=
_t salen,
> > -				struct pmap *pmap)
> > +			     struct pmap *pmap, int checkv4)
> >  {
> >  	if (pmap->pm_vers && pmap->pm_prot && pmap->pm_port)
> >  		return 1;
> > =20
> >  	if (nfs_mount_data_version >=3D 4) {
> >  		const unsigned int *probe_proto;
> > +		int ret;
> > +		struct pmap save_pmap;
> > +		struct sockaddr_storage save_sa;
> > =20
> >  		probe_proto =3D nfs_default_proto();
> > -
> > -		return nfs_probe_port(sap, salen, pmap,
> > -					probe_nfs3_only, probe_proto);
> > +		memcpy(&save_pmap, pmap, sizeof(save_pmap));
> > +		memcpy(&save_sa, sap, salen);
> > +
> > +		ret =3D nfs_probe_port(sap, salen, pmap,
> > +				     probe_nfs3_only, probe_proto);
> > +		if (!ret || !checkv4 || probe_proto !=3D probe_tcp_first)
> > +			return ret;
> > +		save_pmap.pm_vers =3D 4;
> > +		ret =3D nfs_probe_port((struct sockaddr*)&save_sa, salen, &save_pmap,
> > +				     probe_nfs4_only, probe_tcp_only);
> > +		if (ret) {
> > +			rpc_createerr.cf_stat =3D RPC_FAILED;
> > +			rpc_createerr.cf_error.re_errno =3D EAGAIN;
> > +			return 0;
> > +		}
> > +		return 1;
> >  	} else
> >  		return nfs_probe_port(sap, salen, pmap,
> >  					probe_nfs2_only, probe_udp_only);
> > @@ -671,7 +697,7 @@ static int nfs_probe_version_fixed(const struct soc=
kaddr *mnt_saddr,
> >  			const socklen_t nfs_salen,
> >  			struct pmap *nfs_pmap)
> >  {
> > -	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap))
> > +	if (!nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap, 0))
> >  		return 0;
> >  	return nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap);
> >  }
> > @@ -686,6 +712,8 @@ static int nfs_probe_version_fixed(const struct soc=
kaddr *mnt_saddr,
> >   * @nfs_salen:	length of NFS server's address
> >   * @nfs_pmap:	IN: partially filled-in NFS RPC service tuple;
> >   *		OUT: fully filled-in NFS RPC service tuple
> > + * @checkv4:	Flag indicating that if v3 is available we must also
> > + *		check v4, and if that is available, set re_errno to EAGAIN.
> >   *
> >   * Returns 1 and fills in both @pmap structs if the requested service
> >   * ports are unambiguous and pingable.  Otherwise zero is returned;
> > @@ -696,7 +724,8 @@ int nfs_probe_bothports(const struct sockaddr *mnt_=
saddr,
> >  			struct pmap *mnt_pmap,
> >  			const struct sockaddr *nfs_saddr,
> >  			const socklen_t nfs_salen,
> > -			struct pmap *nfs_pmap)
> > +			struct pmap *nfs_pmap,
> > +			int checkv4)
> >  {
> >  	struct pmap save_nfs, save_mnt;
> >  	const unsigned long *probe_vers;
> > @@ -717,7 +746,7 @@ int nfs_probe_bothports(const struct sockaddr *mnt_=
saddr,
> > =20
> >  	for (; *probe_vers; probe_vers++) {
> >  		nfs_pmap->pm_vers =3D mntvers_to_nfs(*probe_vers);
> > -		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap) !=3D 0) {
> > +		if (nfs_probe_nfsport(nfs_saddr, nfs_salen, nfs_pmap, checkv4) !=3D =
0) {
> >  			mnt_pmap->pm_vers =3D *probe_vers;
> >  			if (nfs_probe_mntport(mnt_saddr, mnt_salen, mnt_pmap) !=3D 0)
> >  				return 1;
> > @@ -757,7 +786,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_a=
ddr_t *nfs_server)
> >  	return nfs_probe_bothports(mnt_addr, sizeof(mnt_server->saddr),
> >  					&mnt_server->pmap,
> >  					nfs_addr, sizeof(nfs_server->saddr),
> > -					&nfs_server->pmap);
> > +					&nfs_server->pmap, 0);
> >  }
> > =20
> >  /**
> > diff --git a/utils/mount/network.h b/utils/mount/network.h
> > index 9c75856c9ca8..d7636d7c54a6 100644
> > --- a/utils/mount/network.h
> > +++ b/utils/mount/network.h
> > @@ -42,7 +42,7 @@ static const struct timeval RETRY_TIMEOUT =3D { 3, 0 =
};
> >  int probe_bothports(clnt_addr_t *, clnt_addr_t *);
> >  int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
> >  			struct pmap *, const struct sockaddr *,
> > -			const socklen_t, struct pmap *);
> > +			const socklen_t, struct pmap *, int);
> >  int nfs_gethostbyname(const char *, struct sockaddr_in *);
> >  int nfs_lookup(const char *hostname, const sa_family_t family,
> >  		struct sockaddr *sap, socklen_t *salen);
> > diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> > index a642394d2f5a..1f4782563572 100644
> > --- a/utils/mount/stropts.c
> > +++ b/utils/mount/stropts.c
> > @@ -484,7 +484,7 @@ static int nfs_construct_new_options(struct mount_o=
ptions *options,
> >   * FALSE is returned if some failure occurred.
> >   */
> >  static int
> > -nfs_rewrite_pmap_mount_options(struct mount_options *options)
> > +nfs_rewrite_pmap_mount_options(struct mount_options *options, int chec=
kv4)
> >  {
> >  	union nfs_sockaddr nfs_address;
> >  	struct sockaddr *nfs_saddr =3D &nfs_address.sa;
> > @@ -534,7 +534,7 @@ nfs_rewrite_pmap_mount_options(struct mount_options=
 *options)
> >  	 * negotiate.  Bail now if we can't contact it.
> >  	 */
> >  	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
> > -				 nfs_saddr, nfs_salen, &nfs_pmap)) {
> > +				 nfs_saddr, nfs_salen, &nfs_pmap, checkv4)) {
> >  		errno =3D ESPIPE;
> >  		if (rpc_createerr.cf_stat =3D=3D RPC_PROGNOTREGISTERED)
> >  			errno =3D EOPNOTSUPP;
> > @@ -595,7 +595,8 @@ static int nfs_sys_mount(struct nfsmount_info *mi, =
struct mount_options *opts)
> >  }
> > =20
> >  static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> > -		struct sockaddr *sap, socklen_t salen)
> > +			     struct sockaddr *sap, socklen_t salen,
> > +			     int checkv4)
> >  {
> >  	struct mount_options *options =3D po_dup(mi->options);
> >  	int result =3D 0;
> > @@ -637,7 +638,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *=
mi,
> >  		printf(_("%s: trying text-based options '%s'\n"),
> >  			progname, *mi->extra_opts);
> > =20
> > -	if (!nfs_rewrite_pmap_mount_options(options))
> > +	if (!nfs_rewrite_pmap_mount_options(options, checkv4))
> >  		goto out_fail;
> > =20
> >  	result =3D nfs_sys_mount(mi, options);
> > @@ -653,13 +654,13 @@ out_fail:
> >   * Returns TRUE if successful, otherwise FALSE.
> >   * "errno" is set to reflect the individual error.
> >   */
> > -static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
> > +static int nfs_try_mount_v3v2(struct nfsmount_info *mi, int checkv4)
> >  {
> >  	struct addrinfo *ai;
> >  	int ret =3D 0;
> > =20
> >  	for (ai =3D mi->address; ai !=3D NULL; ai =3D ai->ai_next) {
> > -		ret =3D nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen);
> > +		ret =3D nfs_do_mount_v3v2(mi, ai->ai_addr, ai->ai_addrlen, checkv4);
> >  		if (ret !=3D 0)
> >  			return ret;
> > =20
> > @@ -793,7 +794,8 @@ static int nfs_autonegotiate(struct nfsmount_info *=
mi)
> >  	result =3D nfs_try_mount_v4(mi);
> >  	if (result)
> >  		return result;
> > -	=09
> > +
> > +check_errno:
> >  	switch (errno) {
> >  	case EPROTONOSUPPORT:
> >  		/* A clear indication that the server or our
> > @@ -807,12 +809,24 @@ static int nfs_autonegotiate(struct nfsmount_info=
 *mi)
> >  		/* Linux servers prior to 2.6.25 may return
> >  		 * EPERM when NFS version 4 is not supported. */
> >  		goto fall_back;
> > +	case ECONNREFUSED:
> > +		/* UDP-Only servers won't support v4, but maybe it
> > +		 * just isn't ready yet.  So try v3, but double-check
> > +		 * with rpcbind for v4. */
> > +		result =3D nfs_try_mount_v3v2(mi, 1);
> > +		if (result =3D=3D 0 && errno =3D=3D EAGAIN) {
> > +			/* v4 server seems to be registered now. */
> > +			result =3D nfs_try_mount_v4(mi);
> > +			if (result =3D=3D 0 && errno !=3D ECONNREFUSED)
> > +				goto check_errno;
> > +		}
> > +		return result;
> >  	default:
> >  		return result;
> >  	}
> > =20
> >  fall_back:
> > -	return nfs_try_mount_v3v2(mi);
> > +	return nfs_try_mount_v3v2(mi, 0);
> >  }
> > =20
> >  /*
> > @@ -831,7 +845,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
> >  		break;
> >  	case 2:
> >  	case 3:
> > -		result =3D nfs_try_mount_v3v2(mi);
> > +		result =3D nfs_try_mount_v3v2(mi, 0);
> >  		break;
> >  	case 4:
> >  		result =3D nfs_try_mount_v4(mi);
> >=20


--Sig_/SJzNSggD=I0z68K2qibJg9N
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx42NDnsnt1WYoG5AQLDGxAAgxroeMTELM4kzCT3wzd7tLD4o19G56JA
jdlNe27OJnmo/KbiItvEcS8HT0Jd8ZQDNAvnUGHbUsWqk1zn0NtFgkCdRdtFXNgr
cILnQ0dPj6Bpuq0FQ732GzmLD3Pljdk38Z81lTKusTGnc9r0HRYn9Z56HaUU3brx
MQBhGp9DOuJgL6d1k+kDN92wcTLmwapAAqLxiJO+x/YXOnROAcy86wpdHls6+F3g
hYSCttLhao6EdMAJ27LHUFjwRccJa3mnNMH+Hiniw4z+TYCULLoJZyOUgOT5L7Gx
9kKUGcpMJwzchHZ9bI15uZ78bPGUALtvXmfZs/03GYeeh1k2rL2qFSp1ER1L0feY
84U22dCl7cH7wQCMU2+ZmWPWD3NVWpzKZbY1WBBhCD65OAp6EXvnSeiarKd+RG3N
6oWpLVGFAmLKE6F8F7RjEyP3prSArs1Za1zCsp33wFCjQWaF+RZyAo+RvGWvhurv
POMhK/Ckn2mOLVwgDodNHMcHKPJaPvBYL6dHEmtCDIFd2dvQ1MDYxqZ0c1hU+h0j
mJnkiltAdZ96FhLjuErGCspuwOkz2HLlsPTmXSpsuuZK3kwJMUNYCY8UxFNnpULY
sFBibiRElun6HHOTUkBfG2/jvp5M/ydv8xrO9DxkRTythgAW4CViPCrw+XE6rJpc
6UNZ2axvqUk=
=bwww
-----END PGP SIGNATURE-----

--Sig_/SJzNSggD=I0z68K2qibJg9N--
