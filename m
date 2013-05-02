Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51436 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133Ab3EBDNn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 May 2013 23:13:43 -0400
Date: Thu, 2 May 2013 13:13:32 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
Message-ID: <20130502131332.5c0ce2b0@notabene.brown>
In-Reply-To: <1366380998-2581-1-git-send-email-steved@redhat.com>
References: <1366380998-2581-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/qmS7K0u3XvX+V1JBc7z9jJm"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qmS7K0u3XvX+V1JBc7z9jJm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Coming to the party a bit late....

On Fri, 19 Apr 2013 10:16:38 -0400 Steve Dickson <steved@redhat.com> wrote:

> From: Simo Sorce <simo@redhat.com>
>=20
> A NFS client should be able to work properly even if the DNS Reverse
> record for the server is not set. This means a DNS lookup should not be
> done on server names at are passed to GSSAPI. This patch changes the defa=
ult
> behavior to no longer do those types of lookups

OK, this is confusing,  When you do a "DNS lookup .. on server names",
that is a Forward lookup, not a Reverse lookup.

>=20
> This change default behavior could negatively impact some current
> environments, so the -D option is also being added that will re-enable
> the DNS reverse looks on server names, which are passed to GSSAPI.

Which current environments?  Mine?  Maybe the man page update will tell me.
I'll look.


>=20
> Signed-off-by: Simo Sorce <simo@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/gss_util.h  |  2 ++
>  utils/gssd/gssd.c      |  7 +++++--
>  utils/gssd/gssd.man    |  8 +++++++-
>  utils/gssd/gssd_proc.c | 31 +++++++++++++++++++++++++++----
>  4 files changed, 41 insertions(+), 7 deletions(-)
>=20
> diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
> index aa9f778..c81fc5a 100644
> --- a/utils/gssd/gss_util.h
> +++ b/utils/gssd/gss_util.h
> @@ -52,4 +52,6 @@ int gssd_check_mechs(void);
>  		gss_krb5_set_allowable_enctypes(min, cred, num, types)
>  #endif
> =20
> +extern int avoid_dns;
> +
>  #endif /* _GSS_UTIL_H_ */
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 07b1e52..8ee478b 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -85,7 +85,7 @@ sig_hup(int signal)
>  static void
>  usage(char *progname)
>  {
> -	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir]=
 [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
> +	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir]=
 [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm] [-D]\n",
>  		progname);
>  	exit(1);
>  }
> @@ -102,7 +102,7 @@ main(int argc, char *argv[])
>  	char *progname;
> =20
>  	memset(ccachesearch, 0, sizeof(ccachesearch));
> -	while ((opt =3D getopt(argc, argv, "fvrlmnMp:k:d:t:R:")) !=3D -1) {
> +	while ((opt =3D getopt(argc, argv, "DfvrlmnMp:k:d:t:R:")) !=3D -1) {
>  		switch (opt) {
>  			case 'f':
>  				fg =3D 1;
> @@ -150,6 +150,9 @@ main(int argc, char *argv[])
>  				errx(1, "Encryption type limits not supported by Kerberos libraries.=
");
>  #endif
>  				break;
> +			case 'D':
> +				avoid_dns =3D 0;
> +				break;
>  			default:
>  				usage(argv[0]);
>  				break;
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index 79d9bf9..1df75c5 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -8,7 +8,7 @@
>  rpc.gssd \- RPCSEC_GSS daemon
>  .SH SYNOPSIS
>  .B rpc.gssd
> -.RB [ \-fMnlvr ]
> +.RB [ \-DfMnlvr ]
>  .RB [ \-k
>  .IR keytab ]
>  .RB [ \-p
> @@ -195,6 +195,12 @@ option when starting
>  .BR rpc.gssd .
>  .SH OPTIONS
>  .TP
> +.B -D
> +DNS Reverse lookups are not used for determining the
> +server names pass to GSSAPI. This option will reverses that and forces=20
> +the use of DNS Reverse resolution of the server's IP address to=20
> +retrieve the server name to use in GSAPI authentication.
> +.TP

Nope.  "This option will reverses that" doesn't give me a lot of confidence
either.
May I try?


 The server name passed to GSSAPI (whatever that is) for authorisation (or =
is
 it authentication) is normally the name exactly as requested.  e.g. for NFS
 it is the server name in the "servername:/path" mount request.  Only if th=
is
 servername appears to be an IP address (IPv4 or IPv6) will a reverse DNS l=
ookup
 will be performed to get the canoncial server name.
 If this -D option is present, a reverse DNS lookup will *always* be used,
 even if the server name looks like a canonical name.  So it is needed if p=
artially
 qualified, or non canonical names are regularly used.
 Using -D can introduce a security vulnerability, so it is recommended that
 -D not be used, and that canonical names always be used when requesting
 services.

Ahh.. now I know if I might need -D... Assuming the code is correct..


>  .B -f
>  Runs
>  .B rpc.gssd
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index d6f07e6..e4ab253 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -67,6 +67,7 @@
>  #include <errno.h>
>  #include <gssapi/gssapi.h>
>  #include <netdb.h>
> +#include <ctype.h>
> =20
>  #include "gssd.h"
>  #include "err_util.h"
> @@ -107,6 +108,9 @@ struct pollfd * pollarray;
> =20
>  unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
> =20
> +/* Avoid DNS reverse lookups on server names */
> +int avoid_dns =3D 1;
> +
>  /*
>   * convert a presentation address string to a sockaddr_storage struct. R=
eturns
>   * true on success or false on failure.
> @@ -165,12 +169,31 @@ addrstr_to_sockaddr(struct sockaddr *sa, const char=
 *node, const char *port)
>   * convert a sockaddr to a hostname
>   */
>  static char *
> -sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
> +get_servername(const char *name, const struct sockaddr *sa, const char *=
addr)
>  {
>  	socklen_t		addrlen;
>  	int			err;
>  	char			*hostname;
>  	char			hbuf[NI_MAXHOST];
> +	unsigned char		buf[sizeof(struct in6_addr)];
> +	int			servername =3D 0;
> +
> +	if (avoid_dns) {
> +		/*
> +		 * Determine if this is a server name, or an IP address.
> +		 * If it is an IP address, do the DNS lookup otherwise
> +		 * skip the DNS lookup.
> +		 */
> +		servername =3D 0;
> +		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) =3D=3D 1)
> +			servername =3D 1; /* IPv4 */
> +		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) =3D=3D 1)
> +			servername =3D 1; /* or IPv6 */
> +
> +		if (servername) {
> +			return strdup(name);
> +		}
> +	}

Uh oh.  Look at that code.  Now look at me.  Now back at the code.
Now look at this code that was prepared earlier (in Take 2).

+	if (avoid_dns) {
+		/*
+		 * Determine if this is a server name, or an IP address.
+		 * If it is an IP address, do the DNS lookup
+		 */
+		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) =3D=3D 1)
+			do_dns_lookup =3D 1; /* IPv4 */
+		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) =3D=3D 1)
+			do_dns_lookup =3D 1; /* or IPv6 */
+
+		if (!do_dns_lookup) {
+			return strdup(name);
+		}
+	}

So we changed "do_dns_lookup" to "servername", set it to zero one more time
(just to be sure), and the final condition has been REVERSED.
So if I use an IP address, that is the string passed back to GSSAPI.
If I used a fully qualified name (like the man page suggests), then it goes=
 to
do a reverse DNS lookup for me :-(

And was there a reason for dropping the test on "non-qualified host name"
that was in the original?  That seemed like a good idea to me.

Is inet_pton so expensive that we need to do the 'strchr' first to avoid the
extra work?

Are we going to get a 1-2-9 once this has been fixed properly ?

Possible patch below.  Note that I also needed

diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index f1d0bf8..b57e504 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -7,6 +7,7 @@
 #ifdef HAVE_CONFIG_H
 #include <config.h>
 #endif
+#include <stdlib.h>
=20
 #include <netdb.h>
 #include <arpa/inet.h>


to get a clean compile.

Or mostly clean. On openSUSE I also get:

gssd-context_lucid.o: In function `serialize_krb5_ctx':
/home/git/nfs-utils/utils/gssd/context_lucid.c:269: undefined reference to =
`gss_krb5_export_lucid_sec_context'
/home/git/nfs-utils/utils/gssd/context_lucid.c:305: undefined reference to =
`gss_krb5_free_lucid_sec_context'
gssd-krb5_util.o: In function `limit_krb5_enctypes':
/home/git/nfs-utils/utils/gssd/krb5_util.c:1441: undefined reference to `gs=
s_krb5_set_allowable_enctypes'
/home/git/nfs-utils/utils/gssd/krb5_util.c:1444: undefined reference to `gs=
s_krb5_set_allowable_enctypes'
collect2: error: ld returned 1 exit status


any idea what is causing that"?


Subject: Fix recent fix to Avoid DNS reverse resolution in gssd.

The final version for this fix that was committed inverted the test
so makes no change in the important cases.
The documentation didn't really help a naive user know when the new -D flag
should be used.
And the code (once fixed) avoided DNS resolution on non-qualified names too,
which probably isn't a good idea.

This patch fixes all three issues.

Signed-off-by: NeilBrown <neilb@suse.de>


diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 1df75c5..ac13fd4 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -195,11 +195,28 @@ option when starting
 .BR rpc.gssd .
 .SH OPTIONS
 .TP
-.B -D
-DNS Reverse lookups are not used for determining the
-server names pass to GSSAPI. This option will reverses that and forces=20
-the use of DNS Reverse resolution of the server's IP address to=20
-retrieve the server name to use in GSAPI authentication.
+.B \-D
+The server name passed to GSSAPI for authentication is normally the
+name exactly as requested.  e.g. for NFS
+it is the server name in the "servername:/path" mount request.  Only if th=
is
+servername appears to be an IP address (IPv4 or IPv6) or an
+unqualified name (no dots) will a reverse DNS lookup
+will be performed to get the canoncial server name.
+
+If
+.B \-D
+is present, a reverse DNS lookup will
+.I always
+be used, even if the server name looks like a canonical name.  So it
+is needed if partially qualified, or non canonical names are regularly
+used.
+
+Using
+.B \-D
+can introduce a security vulnerability, so it is recommended that
+.B \-D
+not be used, and that canonical names always be used when requesting
+services.
 .TP
 .B -f
 Runs
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index af1844c..d381664 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -176,7 +176,6 @@ get_servername(const char *name, const struct sockaddr =
*sa, const char *addr)
 	char			*hostname;
 	char			hbuf[NI_MAXHOST];
 	unsigned char		buf[sizeof(struct in6_addr)];
-	int			servername =3D 0;
=20
 	if (avoid_dns) {
 		/*
@@ -184,15 +183,18 @@ get_servername(const char *name, const struct sockadd=
r *sa, const char *addr)
 		 * If it is an IP address, do the DNS lookup otherwise
 		 * skip the DNS lookup.
 		 */
-		servername =3D 0;
-		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) =3D=3D 1)
-			servername =3D 1; /* IPv4 */
-		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) =3D=3D 1)
-			servername =3D 1; /* or IPv6 */
-
-		if (servername) {
+		int is_fqdn =3D 1;
+		if (strchr(name, '.') =3D=3D NULL)
+			is_fqdn =3D 0; /* local name */
+		else if (inet_pton(AF_INET, name, buf) =3D=3D 1)
+			is_fqdn =3D 0; /* IPv4 address */
+		else if (inet_pton(AF_INET6, name, buf) =3D=3D 1)
+			is_fqdn =3D 0; /* IPv6 addrss */
+
+		if (is_fqdn) {
 			return strdup(name);
 		}
+		/* Sorry, cannot avoid dns after all */
 	}
=20
 	switch (sa->sa_family) {

--Sig_/qmS7K0u3XvX+V1JBc7z9jJm
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUYHZ3Dnsnt1WYoG5AQJpSg//fLeFfwj9ID6gF9ObROOS8y+bNsqnKhAi
Mm12OlAc4Lw8Dmwo1D5Stk7fkbKarPpgeNzDuKoQqQ/FcaRw4CPjzDHXElPeRvXj
y+yBCbXfiPFELXU3gzRZ2m5cMKYh4TJ9pBVNh+BpNHf2itIfx0+aeGLYfa0nYOXC
/TPPSJSzCFOAIJQqGp7uodUSufXnF1R80FxDk9NZ1XPvX1sRx1XTq3kPb3oQGwOu
qOuBwYam812eRYvsjjZDPX3/pvChzti0TWhZ0diqw5RzxJAYdTF88Bl+B9O5Gvn1
IijvFJQBiEHCvPKY2TMcadopZEajZ7jLdIA/WsI3rKSbOqA5Jj+dU9IdI0IpqCaz
kJnJj0qlN+UJL23DN+wuegtj+nPFtdMkqv5p4uy/680LfQ6/n9M+sz04mR5sOK13
rRY4TuK4paM3B/GvPbR1UPwDlbyDqy+CZlXJTXoZ7J/CyJEcV3qM8wkWwQEWDuYS
B0x94/3/Fe27aEBehrdFSxeJD1LxOr08WtZqCgTm955sWzgAZhxjC1FDiF8MuOGk
9W1dFNpZuiM/mOerP641I7n+kLzjAm2cvXfkxcZ874DmaSOuxO+FcBlIfdIbzrRK
IzM6st76lToLAKD9xumjamg5+DTldMo6qnT1hna5BkdZRfg84x1tGexnDiQAzwIT
XrHD0Q/BLKw=
=UldU
-----END PGP SIGNATURE-----

--Sig_/qmS7K0u3XvX+V1JBc7z9jJm--
