Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:44826 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753686AbeFDPDe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 11:03:34 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH 1/4] xtab.c: Removed overflow in implicit constant
 conversion errors
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180604145051.146390-2-steved@redhat.com>
Date: Mon, 4 Jun 2018 11:03:19 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4EACDD0C-7BBF-4267-BB60-53DCD0E05256@oracle.com>
References: <20180604145051.146390-1-steved@redhat.com>
 <20180604145051.146390-2-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 4, 2018, at 10:50 AM, Steve Dickson <steved@redhat.com> wrote:
>=20
> xtab.c: In function 'xtab_read':
> xtab.c:60:4: error: overflow in implicit constant conversion
> [-Werror=3Doverflow]
>    exp->m_xtabent =3D 1;
>    ^
> xtab.c:61:4: error: overflow in implicit constant conversion
> [-Werror=3Doverflow]
>    exp->m_mayexport =3D 1;
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> support/include/exportfs.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/support/include/exportfs.h b/support/include/exportfs.h
> index 8af47a8..a82a9b8 100644
> --- a/support/include/exportfs.h
> +++ b/support/include/exportfs.h
> @@ -97,7 +97,7 @@ typedef struct mexport {
> 	struct mclient *	m_client;
> 	struct exportent	m_export;
> 	int			m_exported;	/* known to knfsd. */
> -	int			m_xtabent  : 1,	/* xtab entry exists */
> +	unsigned int m_xtabent : 1,	/* xtab entry exists */

Nit: White space damage. "m_xtabent" and the colon should line up with =
the following fields.

Overall these look like all the errors I hit. Thanks for the fixes!


> 				m_mayexport: 1,	/* derived from xtabbed =
*/
> 				m_changed  : 1, /* options (may) have =
changed */
> 				m_warned   : 1; /* warned about multiple =
exports
> --=20
> 1.8.3.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



