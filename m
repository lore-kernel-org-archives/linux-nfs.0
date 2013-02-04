Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53382 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755197Ab3BDXnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 18:43:04 -0500
Date: Tue, 5 Feb 2013 10:42:43 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Kevin Coffman <kwc@citi.umich.edu>,
        "J.Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Corrupted RPC_GSS_PROC_DESTROY packets coming from Linux
 servers.
Message-ID: <20130205104243.07894feb@notabene.brown>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA918343FBB@sacexcmbx05-prd.hq.netapp.com>
References: <20130124130243.449d5d92@notabene.brown>
	<FF0F3E98-5C30-4EFB-BE7C-783AB0660147@oracle.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA918343FBB@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/o2Vsw.=ZaM8QwSP_LASl1Jd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/o2Vsw.=ZaM8QwSP_LASl1Jd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 30 Jan 2013 23:19:20 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Chuck Lever
> > Sent: Thursday, January 24, 2013 11:14 AM
> > To: NeilBrown
> > Cc: Kevin Coffman; J.Bruce Fields; Steve Dickson; NFS
> > Subject: Re: Corrupted RPC_GSS_PROC_DESTROY packets coming from Linux
> > servers.
> >=20
> >=20
> > On Jan 23, 2013, at 9:02 PM, NeilBrown <neilb@suse.de> wrote:
> >=20
> > >
> > > Hi peoples,
> > >
> > > this issue has appeared on the mailing list before (particularly
> > > around July
> > > 2011) but hasn't been resolved yet and it just bit me again so I
> > > figure it is time it got fixed.
> > >
> > >
> > > If you tcpdump the network connection while mounting an NFS filesystem
> > > using kerberos - or while the client is establishing a new context
> > > because e.g. the server rebooted - you will see a NULL RPC with an
> > > RPC_GSS_PROC_DESTROY credential but no verifier.  The lack of a
> > > verifier makes the packet corrupt so the server ignores it, but people
> > > see it and think something is wrong.
> > >
> > > It is good that the server ignores it as it really shouldn't be there.
> > > What happens is that the NFS client calls up to rpc.gssd to request a
> > > credential.  rpc.gssd then establishes a connection directly with the
> > > server, including the establishment of the security context.  Then it
> > > gathers the context details and passed them down to the kernel.
> > > Then it closes the connection part of which involves calling
> > > AUTH_DESTROY(auth) - necessary to free up data structures and not leak
> > > memory.
> > > This AUTH_DESTROY tries to destroy the context completely, including
> > > telling the server that it has been destroyed! But it hasn't, it has
> > > just been passed down to the kernel for use on a different connection.
> > >
> > > So there are two issues here:
> > >  - why is the GSS_PROC_DESTROY packet missing a verifier
> > >  - how can we get AUTH_DESTROY to *not* try to destroy the context on
> > the
> > >    server - as that would be a bad thing.
> > >
> > > The first I cannot completely answer.  I do  know that in libtirpc, in
> > > auth_gss.c, in authgss_marshal(), gss_get_mic is failing because it d=
oesn't
> > > think it has a valid context.   I don't know why it thinks that, and =
I don't
> > > really care.
> > >
> > >
> > > The second question is more interesting and I see two possible option=
s.
> > >
> > > 1/ If we knew why gss_get_mic failed and had good reason to believe it
> > > would keep on failing, we could consider changing clnt_vc_call to
> > > respond to an error from AUTH_MARSHALL not by sending a truncated
> > > packet, but by purging the current message and not sending it at all.
> > > This should be possible but might be messy.
> > >
> > > 2/ Make libtirpc behave more like librpcsecgss.
> > >  In libtirpc, the authgss_get_private_data() function just hands over
> > > a  pointer to the private data, but keeps its own pointer so it can
> > > free it  when the client is finally destroyed.
> > >
> > >  In librpcsecgss, since commit
> > > 07fce317cac267509b944a8191cafa8e49b5e328
> > >  (thanks Kevin), authgss_get_private_data() hands the data over to the
> > > caller and doesn't keep it's own reference to it.  So the caller has
> > > to call
> > >  authgss_free_private_data() when it has finished with the data.
> > >  As the library no longer has the credential, it doesn't even bother
> > > trying  to send a GSS_PROC_DESTROY request.
> > >
> > >  When Chuck noticed this difference between the two libraries, he
> > > resolved  it - in commit 336f8bca825416082d62ef38314f3e0b7e8f5cc2 as
> > follow:
> > >
> > >        if (token.value)
> > >                free(token.value);
> > > +#ifndef HAVE_LIBTIRPC
> > >        if (pd.pd_ctx_hndl.length !=3D 0)
> > >                authgss_free_private_data(&pd);
> > > +#endif
> > >
> > >  Clearly to significance of this difference was not obvious, and this
> > > was  the easiest fix.
> > >
> > >  If we were to "fix" this properly, we would need to add a commit like
> > > the  one from Kevin to libtirpc, and remove that #ifndef from nfs-uti=
ls.
> > >  co-ordinating this might be tricking.  nfs-utils could presumably
> > > test if  libtirpc provided the function (at configure time) and call
> > > it if it does,
> >=20
> > This seems to me like the best approach for 2.
> >=20
> > >  However is someone updates libtirpc without updating or recompiling
> > > nfs-utils they would get a memory leak.  May it would be slow enough
> > > not to  be serious, and if anyone noticed that could just upgrade and=
 get a
> > fix.
> >=20
> > Telling people to upgrade for a fix is what we do for a living.  In all
> > seriousness, though, in the common case, people will be using nfs-utils=
 and
> > libtirpc built by distributions, and we expect the distros will get the=
 fix
> > dependency right over time.
> >=20
> > >  Does this seem reasonable?   How is maintaining libtirpc these days?
> > >  Could we get the fix into 0.2.3, or would we need a minor version
> > > bump to  0.3.0??
> >=20
> > A minor version bump shouldn't be necessary if we're not changing the
> > synopsis of a published API, nor are we removing a published API.
> >=20
> > > 3/ there is actually a third option.  We could change
> > > authgss_get_private_data() to set gc.gc_ctx.length to 0, but not free
> > > the buffer.  Then aithgss_destroy_context() could notice that the
> > > length is zero and the buffer is not NULL, and could free the buffer =
but not
> > try to send
> > > the context_destroy request.   It's an ugly hack though and I think I=
'd
> > > rather not.
>=20
> 4/ Have authgss_get_private_data() consume the 'auth' argument.
>=20
> Reusing the auth in an RPC call after we've transferred the context to th=
e kernel is in any case a bug, so why allow it at all?
>=20

This is exactly the same as '2' - though stated much more succinctly.  It
looks like it is the approach that everyone prefers.
I'll send some patches.

Thanks,
NeilBrown

--Sig_/o2Vsw.=ZaM8QwSP_LASl1Jd
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBURBHcznsnt1WYoG5AQIrow/+O0uicjju63djWGOAt1/W719V3cFM/hpf
vgyn8IHivrZGfheVlM5gTc/I6+ZBLeVXX/HCcTgnN5jxAHwUot2IT75XKJtJtdaq
C5stJF6GmSWtQXMnSiStQ9vSJS4bwrEX6p+xYfnmINONs3WI/vY3Arhtfd1P0QZ7
+SBgohtCWW773gZvIFO4cLhBAY2bPvMOtBA4S0U6pwvUlimZL52CJeX8K2Do047b
A2jIET0y1jQdVzjxAMh0lwmisRhZaY2ro8ogfijjbTUWfF0Czt2A+WFvBKb6mjpP
602mtF09On5/OuYfFx0653iOBl54sBh5gRSOYicwEgkrMYH2LRT+mffrHFEq6Kwo
2P5obP8piuQibbur5SL1BSqESPjeASkz9UQR544W6IPDy6cA0OQS3Rn0TpdRGpVm
DofeCpz4te7pckfbZIbl11Kip5IfMQUEVgY8N4mzEYYrrkPA/a5YLe642PqTCZc+
ybhzuruahIlzqKhKtrzFZa9c9PGboxOqQwK/iVXi/5U/sbseY8K5E0hJ0XfS9DZN
/wRcOMPak7FAyTd8RHGMsIWdKY4sExk15oQRDkI5RP/CXvmb/aewwDP+tD8fEj3V
ZOisUMrpPfX8b/EpvqpxLJm8plh3NC3fqGPBSVlse+wJMnVBHUrpNPUvpe0Sr67/
wqSWPacFXfs=
=GVx8
-----END PGP SIGNATURE-----

--Sig_/o2Vsw.=ZaM8QwSP_LASl1Jd--
