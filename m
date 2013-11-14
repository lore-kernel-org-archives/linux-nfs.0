Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab3KNBy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 20:54:27 -0500
Date: Wed, 13 Nov 2013 20:56:28 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: trond.myklebust@netapp.com, chuck.lever@oracle.com, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/3] sunrpc: replace sunrpc_net->gssd_running flag
 with a more reliable check
Message-ID: <20131113205628.209af84a@corrin.poochiereds.net>
In-Reply-To: <20131114102448.49ccbf50@notabene.brown>
References: <1384374493-8006-1-git-send-email-jlayton@redhat.com>
	<1384374493-8006-3-git-send-email-jlayton@redhat.com>
	<20131114102448.49ccbf50@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/mY+WAOiEfuG6WU3hkl4zU.Y"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/mY+WAOiEfuG6WU3hkl4zU.Y
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 14 Nov 2013 10:24:48 +1100
NeilBrown <neilb@suse.de> wrote:

> On Wed, 13 Nov 2013 15:28:12 -0500 Jeff Layton <jlayton@redhat.com> wrote:
>=20
> > Now that we have a more reliable method to tell if gssd is running, we
> > can replace the sn->gssd_running flag with a function that will query to
> > see if it's up and running.
> >=20
> > There's also no need to attempt an upcall that we know will fail, so
> > just return -EACCES if gssd isn't running in that case.
> >=20
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  include/linux/sunrpc/rpc_pipe_fs.h | 14 ++++++++++++++
> >  net/sunrpc/auth_gss/auth_gss.c     | 10 +++++-----
> >  net/sunrpc/netns.h                 |  2 --
> >  net/sunrpc/rpc_pipe.c              | 16 ++++++++++++----
> >  4 files changed, 31 insertions(+), 11 deletions(-)
> >=20
> > diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/=
rpc_pipe_fs.h
> > index 85f1342..438e606 100644
> > --- a/include/linux/sunrpc/rpc_pipe_fs.h
> > +++ b/include/linux/sunrpc/rpc_pipe_fs.h
> > @@ -131,5 +131,19 @@ extern int rpc_unlink(struct dentry *);
> >  extern int register_rpc_pipefs(void);
> >  extern void unregister_rpc_pipefs(void);
> > =20
> > +#if IS_ENABLED(CONFIG_SUNRPC_GSS)
> > +
> > +extern bool gssd_running(struct net *net);
> > +
> > +#else /* !CONFIG_SUNRPC_GSS */
> > +
> > +static inline bool
> > +gssd_running(struct net *net)
> > +{
> > +	return false;
> > +}
> > +
> > +#endif /* CONFIG_SUNRPC_GSS */
>=20
> Do we really need IS_ENABLED(CONFIG_SUNRPC_GSS) around this?
>=20
> The function is tiny, and could even be a "static inline" with very little
> cost.
>=20
> Let's just always  define it.
>=20
> But independent of that, the patches look good to me and appear to work.
>=20
> By the way, the current "only impose the 15 second delay the first time"
> doesn't really work.
> If you:
>   mount 10.0.2.2:/home /mnt ; umount /mnt
>=20
> repeatedly then it will take 15-18 seconds every time.
>=20
> This is with rpc.gssd not running, but rpc.idmapd running.
>=20
> As rpc.idmapd opens some rpc-pipe thing, that sets the gssd_running flag.
> So that is an extra reason to get rid of the flag.
>=20
> Thanks,
> NeilBrown

(adding linux-nfs ml to mailing list since I missed it earlier)

Ahh that is interesting...

My rationale here was that even if someone started gssd on a kernel
that didn't have CONFIG_SUNRPC_GSS enabled, that we wouldn't want
gssd_running to return true.

But...you're probably right and there's no need for it. I'll plan to
fix that (and the commit message error you spotted) and resend tomorrow
sometime.

Thanks for the review...
--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/mY+WAOiEfuG6WU3hkl4zU.Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJShC3VAAoJEAAOaEEZVoIV+tgQAIlv9jAzX7XTYPPS/koaI1vx
eCi5DwSRtLgH7Q+xj5iF7iKwv4PLwKymbJfZKb7XlUBDPZvl0DxP3cLsYlZkx3/g
QwA3/IswsMKi8Lh1jyOC1NwBfhqzieIsSIMarxj8ro4hF7J3/dXbfjXKJIPwTIQi
xrViI9G2f8EzkLlO1MrMqMgvgVWHg8l+Vq9MR9SBxaAi/rE54+oSEOVJ1MLHyFur
7aI1wT1CYEoHMOJSAuwHUxkSe994ak2RTF/NOM/BLudi1MCZX6gMEc1eyO0LgDIU
nRGOYs4YJzaO+wIFqIh98fOCZYRsgC/7ENH5ZBiuNLCqIOVcmFH2i1qcmWwHJK1l
WAK2w4YqxdxL1u2bzdWHuuWCc6UoyU40Kgt7SefyWxopmuOdkYHyMVG8/CG6QBi/
pFg2vsrQIhEUSTg9E5/hHnkq8qiUGP7yg4ULDnD4FpQ7OFrDgvLHLJ35Efvm/8sy
WNtKz8JM3Cjr5+G726IyxjcqpzbrQLDBv2xW3EIzK1hu47ium0jdfyA53TUI4jQK
4+1taetr+d2RFaZb8eS4uRGG7nk7KuGxWmlvgc+h0WHbV+teaZN2daga8aAWy1Pa
eIRYYJ3WcAvoJ1tMlnoad9psNocIu8iRNAIh+pu+ymgAd4WLr+8QM1prpxtt4PN9
gPeoPgt15Y3XiHkKFydE
=QKKh
-----END PGP SIGNATURE-----

--Sig_/mY+WAOiEfuG6WU3hkl4zU.Y--
