Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45469 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201Ab3E0XLw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 May 2013 19:11:52 -0400
Date: Tue, 28 May 2013 09:11:39 +1000
From: NeilBrown <neilb@suse.de>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
Message-ID: <20130528091139.36bb362e@notabene.brown>
In-Reply-To: <20130502131332.5c0ce2b0@notabene.brown>
References: <1366380998-2581-1-git-send-email-steved@redhat.com>
	<20130502131332.5c0ce2b0@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/M1HLJNbm=zUmgUbbG.v+9=."; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/M1HLJNbm=zUmgUbbG.v+9=.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Steve,
 what is the status of this issue in your mind?
 upstream nfs-utils is still vulnerable to CVE-2013-1923, so probably a few
 distros think that have addressed it by upgrading, but haven't.

 Can we get a 1.2.9 that really fixes this issue?

Thanks,
NeilBrown


On Thu, 2 May 2013 13:13:32 +1000 NeilBrown <neilb@suse.de> wrote:

>=20
> Coming to the party a bit late....
>=20
> On Fri, 19 Apr 2013 10:16:38 -0400 Steve Dickson <steved@redhat.com> wrot=
e:
>=20
> > From: Simo Sorce <simo@redhat.com>
> >=20
> > A NFS client should be able to work properly even if the DNS Reverse
> > record for the server is not set. This means a DNS lookup should not be
> > done on server names at are passed to GSSAPI. This patch changes the de=
fault
> > behavior to no longer do those types of lookups
>=20
> OK, this is confusing,  When you do a "DNS lookup .. on server names",
> that is a Forward lookup, not a Reverse lookup.
>=20
> >=20
> > This change default behavior could negatively impact some current
> > environments, so the -D option is also being added that will re-enable
> > the DNS reverse looks on server names, which are passed to GSSAPI.
>=20
> Which current environments?  Mine?  Maybe the man page update will tell m=
e.
> I'll look.
>=20
>=20
> >=20
> > Signed-off-by: Simo Sorce <simo@redhat.com>
> > Signed-off-by: Steve Dickson <steved@redhat.com>
> > ---
> >  utils/gssd/gss_util.h  |  2 ++
> >  utils/gssd/gssd.c      |  7 +++++--
> >  utils/gssd/gssd.man    |  8 +++++++-
> >  utils/gssd/gssd_proc.c | 31 +++++++++++++++++++++++++++----
> >  4 files changed, 41 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
> > index aa9f778..c81fc5a 100644
> > --- a/utils/gssd/gss_util.h
> > +++ b/utils/gssd/gss_util.h
> > @@ -52,4 +52,6 @@ int gssd_check_mechs(void);
> >  		gss_krb5_set_allowable_enctypes(min, cred, num, types)
> >  #endif
> > =20
> > +extern int avoid_dns;
> > +
> >  #endif /* _GSS_UTIL_H_ */
> > diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> > index 07b1e52..8ee478b 100644
> > --- a/utils/gssd/gssd.c
> > +++ b/utils/gssd/gssd.c
> > @@ -85,7 +85,7 @@ sig_hup(int signal)
> >  static void
> >  usage(char *progname)
> >  {
> > -	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdi=
r] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
> > +	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdi=
r] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm] [-D]\n",
> >  		progname);
> >  	exit(1);
> >  }
> > @@ -102,7 +102,7 @@ main(int argc, char *argv[])
> >  	char *progname;
> > =20
> >  	memset(ccachesearch, 0, sizeof(ccachesearch));
> > -	while ((opt =3D getopt(argc, argv, "fvrlmnMp:k:d:t:R:")) !=3D -1) {
> > +	while ((opt =3D getopt(argc, argv, "DfvrlmnMp:k:d:t:R:")) !=3D -1) {
> >  		switch (opt) {
> >  			case 'f':
> >  				fg =3D 1;
> > @@ -150,6 +150,9 @@ main(int argc, char *argv[])
> >  				errx(1, "Encryption type limits not supported by Kerberos librarie=
s.");
> >  #endif
> >  				break;
> > +			case 'D':
> > +				avoid_dns =3D 0;
> > +				break;
> >  			default:
> >  				usage(argv[0]);
> >  				break;
> > diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> > index 79d9bf9..1df75c5 100644
> > --- a/utils/gssd/gssd.man
> > +++ b/utils/gssd/gssd.man
> > @@ -8,7 +8,7 @@
> >  rpc.gssd \- RPCSEC_GSS daemon
> >  .SH SYNOPSIS
> >  .B rpc.gssd
> > -.RB [ \-fMnlvr ]
> > +.RB [ \-DfMnlvr ]
> >  .RB [ \-k
> >  .IR keytab ]
> >  .RB [ \-p
> > @@ -195,6 +195,12 @@ option when starting
> >  .BR rpc.gssd .
> >  .SH OPTIONS
> >  .TP
> > +.B -D
> > +DNS Reverse lookups are not used for determining the
> > +server names pass to GSSAPI. This option will reverses that and forces=
=20
> > +the use of DNS Reverse resolution of the server's IP address to=20
> > +retrieve the server name to use in GSAPI authentication.
> > +.TP
>=20
> Nope.  "This option will reverses that" doesn't give me a lot of confiden=
ce
> either.
> May I try?
>=20
>=20
>  The server name passed to GSSAPI (whatever that is) for authorisation (o=
r is
>  it authentication) is normally the name exactly as requested.  e.g. for =
NFS
>  it is the server name in the "servername:/path" mount request.  Only if =
this
>  servername appears to be an IP address (IPv4 or IPv6) will a reverse DNS=
 lookup
>  will be performed to get the canoncial server name.
>  If this -D option is present, a reverse DNS lookup will *always* be used,
>  even if the server name looks like a canonical name.  So it is needed if=
 partially
>  qualified, or non canonical names are regularly used.
>  Using -D can introduce a security vulnerability, so it is recommended th=
at
>  -D not be used, and that canonical names always be used when requesting
>  services.
>=20
> Ahh.. now I know if I might need -D... Assuming the code is correct..
>=20
>=20
> >  .B -f
> >  Runs
> >  .B rpc.gssd
> > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > index d6f07e6..e4ab253 100644
> > --- a/utils/gssd/gssd_proc.c
> > +++ b/utils/gssd/gssd_proc.c
> > @@ -67,6 +67,7 @@
> >  #include <errno.h>
> >  #include <gssapi/gssapi.h>
> >  #include <netdb.h>
> > +#include <ctype.h>
> > =20
> >  #include "gssd.h"
> >  #include "err_util.h"
> > @@ -107,6 +108,9 @@ struct pollfd * pollarray;
> > =20
> >  unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
> > =20
> > +/* Avoid DNS reverse lookups on server names */
> > +int avoid_dns =3D 1;
> > +
> >  /*
> >   * convert a presentation address string to a sockaddr_storage struct.=
 Returns
> >   * true on success or false on failure.
> > @@ -165,12 +169,31 @@ addrstr_to_sockaddr(struct sockaddr *sa, const ch=
ar *node, const char *port)
> >   * convert a sockaddr to a hostname
> >   */
> >  static char *
> > -sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
> > +get_servername(const char *name, const struct sockaddr *sa, const char=
 *addr)
> >  {
> >  	socklen_t		addrlen;
> >  	int			err;
> >  	char			*hostname;
> >  	char			hbuf[NI_MAXHOST];
> > +	unsigned char		buf[sizeof(struct in6_addr)];
> > +	int			servername =3D 0;
> > +
> > +	if (avoid_dns) {
> > +		/*
> > +		 * Determine if this is a server name, or an IP address.
> > +		 * If it is an IP address, do the DNS lookup otherwise
> > +		 * skip the DNS lookup.
> > +		 */
> > +		servername =3D 0;
> > +		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) =3D=3D 1)
> > +			servername =3D 1; /* IPv4 */
> > +		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) =3D=3D =
1)
> > +			servername =3D 1; /* or IPv6 */
> > +
> > +		if (servername) {
> > +			return strdup(name);
> > +		}
> > +	}
>=20
> Uh oh.  Look at that code.  Now look at me.  Now back at the code.
> Now look at this code that was prepared earlier (in Take 2).
>=20
> +	if (avoid_dns) {
> +		/*
> +		 * Determine if this is a server name, or an IP address.
> +		 * If it is an IP address, do the DNS lookup
> +		 */
> +		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) =3D=3D 1)
> +			do_dns_lookup =3D 1; /* IPv4 */
> +		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) =3D=3D 1)
> +			do_dns_lookup =3D 1; /* or IPv6 */
> +
> +		if (!do_dns_lookup) {
> +			return strdup(name);
> +		}
> +	}
>=20
> So we changed "do_dns_lookup" to "servername", set it to zero one more ti=
me
> (just to be sure), and the final condition has been REVERSED.
> So if I use an IP address, that is the string passed back to GSSAPI.
> If I used a fully qualified name (like the man page suggests), then it go=
es to
> do a reverse DNS lookup for me :-(
>=20
> And was there a reason for dropping the test on "non-qualified host name"
> that was in the original?  That seemed like a good idea to me.
>=20
> Is inet_pton so expensive that we need to do the 'strchr' first to avoid =
the
> extra work?
>=20
> Are we going to get a 1-2-9 once this has been fixed properly ?
>=20
> Possible patch below.  Note that I also needed
>=20
> diff --git a/utils/statd/simu.c b/utils/statd/simu.c
> index f1d0bf8..b57e504 100644
> --- a/utils/statd/simu.c
> +++ b/utils/statd/simu.c
> @@ -7,6 +7,7 @@
>  #ifdef HAVE_CONFIG_H
>  #include <config.h>
>  #endif
> +#include <stdlib.h>
> =20
>  #include <netdb.h>
>  #include <arpa/inet.h>
>=20
>=20
> to get a clean compile.
>=20
> Or mostly clean. On openSUSE I also get:
>=20
> gssd-context_lucid.o: In function `serialize_krb5_ctx':
> /home/git/nfs-utils/utils/gssd/context_lucid.c:269: undefined reference t=
o `gss_krb5_export_lucid_sec_context'
> /home/git/nfs-utils/utils/gssd/context_lucid.c:305: undefined reference t=
o `gss_krb5_free_lucid_sec_context'
> gssd-krb5_util.o: In function `limit_krb5_enctypes':
> /home/git/nfs-utils/utils/gssd/krb5_util.c:1441: undefined reference to `=
gss_krb5_set_allowable_enctypes'
> /home/git/nfs-utils/utils/gssd/krb5_util.c:1444: undefined reference to `=
gss_krb5_set_allowable_enctypes'
> collect2: error: ld returned 1 exit status
>=20
>=20
> any idea what is causing that"?
>=20
>=20
> Subject: Fix recent fix to Avoid DNS reverse resolution in gssd.
>=20
> The final version for this fix that was committed inverted the test
> so makes no change in the important cases.
> The documentation didn't really help a naive user know when the new -D fl=
ag
> should be used.
> And the code (once fixed) avoided DNS resolution on non-qualified names t=
oo,
> which probably isn't a good idea.
>=20
> This patch fixes all three issues.
>=20
> Signed-off-by: NeilBrown <neilb@suse.de>
>=20
>=20
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index 1df75c5..ac13fd4 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -195,11 +195,28 @@ option when starting
>  .BR rpc.gssd .
>  .SH OPTIONS
>  .TP
> -.B -D
> -DNS Reverse lookups are not used for determining the
> -server names pass to GSSAPI. This option will reverses that and forces=20
> -the use of DNS Reverse resolution of the server's IP address to=20
> -retrieve the server name to use in GSAPI authentication.
> +.B \-D
> +The server name passed to GSSAPI for authentication is normally the
> +name exactly as requested.  e.g. for NFS
> +it is the server name in the "servername:/path" mount request.  Only if =
this
> +servername appears to be an IP address (IPv4 or IPv6) or an
> +unqualified name (no dots) will a reverse DNS lookup
> +will be performed to get the canoncial server name.
> +
> +If
> +.B \-D
> +is present, a reverse DNS lookup will
> +.I always
> +be used, even if the server name looks like a canonical name.  So it
> +is needed if partially qualified, or non canonical names are regularly
> +used.
> +
> +Using
> +.B \-D
> +can introduce a security vulnerability, so it is recommended that
> +.B \-D
> +not be used, and that canonical names always be used when requesting
> +services.
>  .TP
>  .B -f
>  Runs
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index af1844c..d381664 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -176,7 +176,6 @@ get_servername(const char *name, const struct sockadd=
r *sa, const char *addr)
>  	char			*hostname;
>  	char			hbuf[NI_MAXHOST];
>  	unsigned char		buf[sizeof(struct in6_addr)];
> -	int			servername =3D 0;
> =20
>  	if (avoid_dns) {
>  		/*
> @@ -184,15 +183,18 @@ get_servername(const char *name, const struct socka=
ddr *sa, const char *addr)
>  		 * If it is an IP address, do the DNS lookup otherwise
>  		 * skip the DNS lookup.
>  		 */
> -		servername =3D 0;
> -		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) =3D=3D 1)
> -			servername =3D 1; /* IPv4 */
> -		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) =3D=3D 1)
> -			servername =3D 1; /* or IPv6 */
> -
> -		if (servername) {
> +		int is_fqdn =3D 1;
> +		if (strchr(name, '.') =3D=3D NULL)
> +			is_fqdn =3D 0; /* local name */
> +		else if (inet_pton(AF_INET, name, buf) =3D=3D 1)
> +			is_fqdn =3D 0; /* IPv4 address */
> +		else if (inet_pton(AF_INET6, name, buf) =3D=3D 1)
> +			is_fqdn =3D 0; /* IPv6 addrss */
> +
> +		if (is_fqdn) {
>  			return strdup(name);
>  		}
> +		/* Sorry, cannot avoid dns after all */
>  	}
> =20
>  	switch (sa->sa_family) {


--Sig_/M1HLJNbm=zUmgUbbG.v+9=.
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUaPoKznsnt1WYoG5AQLesQ//We2FzUwa9AwCA1f5XJwcHeTAnBcp4r0f
GDfIEnofj+mz/y1ASjxW4sypv4DvsSxx6bjP85ryGtnpBzor4g1Wb9UFUfO1wNVa
anqw3nJ6pw8r15oJwZxCG0kwMgy98jfJJFSUZH1SSb0mINyZ3RuZolOmuB55JAUU
Qp0UGcXP8pUf/TlcYHyG9tdDa1y8uynP6eU6aPVzDC8PaYuf5Z3m4JssWX3Ox0Nx
hEBuEUCJFJOLl+DLD1wssCnJ2yzKD77HC7CxB04P3OTI2G9YrmdeRwSEa2Y6R//m
vNR/JUuFS9bCXpx8PQ0Su+iiRqbtnLGTW5RQcCHWA/cW/SknMnWmczdGjaNgPxVP
ESCqLFaKvfhnN/VfU3Wo5oO+7xI76M9Ep7tsZUcrZmtVHAOzlSFXshGNFkbrVCk/
wr/2n9BubaHApKXDZlh8rEza5HcT2DdZoGDZ4DGGhmwlpIJveV8xb7ScnMkFlMrp
CXQgHpxQ4y5IGVmyx1//u0l9AL523h6NBb4S9nbrBEq8rtCXkNm1wl8zv01odHrt
slicy8zXCInqjM3Zw2R3pV2JePjnPlCjaVl2NSFC1CUzMD8AdjwMUV/Bdeei2Pnh
WFOx+A2nDJbe2yPS4yiUNgBhAaFsbYldXwK15XiMIxAn/IaLcq1iaRdmzeZ0IEi0
FqYHlgUiATQ=
=/Mm8
-----END PGP SIGNATURE-----

--Sig_/M1HLJNbm=zUmgUbbG.v+9=.--
