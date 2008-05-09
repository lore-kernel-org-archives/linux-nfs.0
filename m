From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] Fix /proc/net/rpc/auth.unix.ip/content output [Was Re:
	stuff]
Date: Fri, 9 May 2008 16:48:07 -0400
Message-ID: <20080509204807.GI1907@fieldses.org>
References: <20080509192319.GG1907@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Aurelien Charbon <aurelien.charbon@bull.net>,
	Neil Brown <neilb@suse.de>, Brian Haley <brian.haley@hp.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38773 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046AbYEIUsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2008 16:48:11 -0400
In-Reply-To: <20080509192319.GG1907@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Um, sorry about that subject line.

On Fri, May 09, 2008 at 03:23:19PM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
>=20
> Commit f15364bd4cf8799a7677b6daeed7b67d9139d974 ("IPv6 support for NF=
S
> server export caches") dropped a couple spaces, rendering the output
> here difficult to read.
>=20
> (However note that we expect the output to be parsed only by humans, =
not
> machines, so this shouldn't have broken any userland software.)
>=20
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> Cc: Aurelien Charbon <aurelien.charbon@bull.net>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Brian Haley <brian.haley@hp.com>
> Cc:  YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshfu=
ji@linux-ipv6.org>
>=20
> ---
>  net/sunrpc/svcauth_unix.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> I just noticed this while doing some debugging at Connectathon.  I'm
> undecided whether to take it seriously.  Does anyone other than me us=
e
> these /content files?  I suppose it should probably go into 2.6.26 bu=
t
> not 2.6.25.x.
>=20
> --b.
>=20
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 3f30ee6..f24800f 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -278,7 +278,7 @@ static int ip_map_show(struct seq_file *m,
>  		dom =3D im->m_client->h.name;
> =20
>  	if (ipv6_addr_v4mapped(&addr)) {
> -		seq_printf(m, "%s" NIPQUAD_FMT "%s\n",
> +		seq_printf(m, "%s " NIPQUAD_FMT " %s\n",
>  			im->m_class,
>  			ntohl(addr.s6_addr32[3]) >> 24 & 0xff,
>  			ntohl(addr.s6_addr32[3]) >> 16 & 0xff,
> @@ -286,7 +286,7 @@ static int ip_map_show(struct seq_file *m,
>  			ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
>  			dom);
>  	} else {
> -		seq_printf(m, "%s" NIP6_FMT "%s\n",
> +		seq_printf(m, "%s " NIP6_FMT " %s\n",
>  			im->m_class, NIP6(addr), dom);
>  	}
>  	return 0;
> --=20
> 1.5.5.rc1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
