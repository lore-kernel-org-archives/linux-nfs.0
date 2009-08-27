From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 2/5] nfsd41: bound forechannel drc size by memory usage
Date: Thu, 27 Aug 2009 13:12:15 -0400
Message-ID: <89c397150908271012w5517b9e8me92d1dbf3074ca3d@mail.gmail.com>
References: <1251389264-3009-1-git-send-email-andros@netapp.com>
	 <1251389264-3009-2-git-send-email-andros@netapp.com>
	 <1251389264-3009-3-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f195.google.com ([209.85.212.195]:39225 "EHLO
	mail-vw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbZH0RMO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2009 13:12:14 -0400
Received: by vws33 with SMTP id 33so993746vws.33
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2009 10:12:15 -0700 (PDT)
In-Reply-To: <1251389264-3009-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2009 at 12:07 PM, <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> By using the requested ca_maxresponsesize_cached * ca_maxresponses to=
 bound
> a forechannel drc request size, clients can tailor a session to usage=
=2E
>
> For example, an I/O session (READ/WRITE only) can have a much smaller
> ca_maxresponsesize_cached (for only WRITE compound responses) and a l=
ot larger
> ca_maxresponses to service a large in-flight data window.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
> =A0fs/nfsd/nfs4state.c =A0 =A0 =A0 =A0| =A0 60 ++++++++++++++++++++++=
+++++++++------------
> =A0include/linux/nfsd/state.h | =A0 =A08 ++++-
> =A02 files changed, 49 insertions(+), 19 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index ddfd36f..a691139 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -414,34 +414,60 @@ gen_sessionid(struct nfsd4_session *ses)
> =A0}
>
> =A0/*
> - * Give the client the number of slots it requests bound by
> - * NFSD_MAX_SLOTS_PER_SESSION and by nfsd_drc_max_mem.
> + * 32 bytes of RPC header and 44 bytes of sequence operation respons=
e
> + * not included in NFSD_SLOT_CACHE_SIZE
> + * */
> +#define NFSD_MIN_HDR_SEQ_SZ =A0(32 + 44)
> +
> +/*
> + * Give the client the number of ca_maxresponsesize_cached slots it =
requests
> + * bounded by NFSD_SLOT_CACHE_SIZE, NFSD_MAX_MEM_PER_SESSION and by
> + * nfsd_drc_max_mem. Do not allow more than NFSD_MAX_SLOTS_PER_SESSI=
ON.
> + *
> + * The ca_maxresponssize_cached definition includes the size
> + * of the rpc header with the variable length security flavor creden=
tial
> + * plus verifier (32 bytes with AUTH_SYS and NULL verifier)
> + * as well as the encoded SEQUENCE operation response (44 bytes)
> + * which are not included in NFSD_SLOT_CACHE_SIZE.
> + * We err on the side of being a bit small when AUTH_SYS/NULL verifi=
er
> + * is not used.
> =A0*
> =A0* If we run out of reserved DRC memory we should (up to a point) r=
e-negotiate
> =A0* active sessions and reduce their slot usage to make rooom for ne=
w
> =A0* connections. For now we just fail the create session.
> =A0*/
> -static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan=
)
> +static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fcha=
n)
> =A0{
> - =A0 =A0 =A0 int mem;
> + =A0 =A0 =A0 int mem, size =3D fchan->maxresp_cached - NFSD_MIN_HDR_=
SEQ_SZ;
>
> - =A0 =A0 =A0 if (fchan->maxreqs < 1)
> + =A0 =A0 =A0 if (fchan->maxreqs < 1 || size <=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return nfserr_inval;
> - =A0 =A0 =A0 else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fchan->maxreqs =3D NFSD_MAX_SLOTS_PER_S=
ESSION;
>
> - =A0 =A0 =A0 mem =3D fchan->maxreqs * NFSD_SLOT_CACHE_SIZE;
> + =A0 =A0 =A0 if (size > NFSD_SLOT_CACHE_SIZE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D NFSD_SLOT_CACHE_SIZE;
> +
> + =A0 =A0 =A0 /* bound the maxreqs by NFSD_MAX_MEM_PER_SESSION */
> + =A0 =A0 =A0 mem =3D fchan->maxreqs * size;
> + =A0 =A0 =A0 if (mem > NFSD_MAX_MEM_PER_SESSION) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fchan->maxreqs =3D NFSD_MAX_MEM_PER_SES=
SION / size;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fchan->maxreqs > NFSD_MAX_SLOTS_PER=
_SESSION)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fchan->maxreqs =3D NFSD=
_MAX_SLOTS_PER_SESSION;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D fchan->maxreqs * size;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0spin_lock(&nfsd_drc_lock);
> - =A0 =A0 =A0 if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D ((nfsd_drc_max_mem - nfsd_drc_m=
em_used) /
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFSD_SL=
OT_CACHE_SIZE) * NFSD_SLOT_CACHE_SIZE;
> + =A0 =A0 =A0 /* bound the total session drc memory ussage */
> + =A0 =A0 =A0 if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fchan->maxreqs =3D (nfsd_drc_max_mem - =
nfsd_drc_mem_used) / size;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D fchan->maxreqs * size;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0nfsd_drc_mem_used +=3D mem;
> =A0 =A0 =A0 =A0spin_unlock(&nfsd_drc_lock);
>
> - =A0 =A0 =A0 fchan->maxreqs =3D mem / NFSD_SLOT_CACHE_SIZE;
> =A0 =A0 =A0 =A0if (fchan->maxreqs =3D=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return nfserr_resource;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return nfserr_serverfault;
               ^^^^^^^^^^^^^^^^^^^
This change belongs in patch [PATCH 4/5] nfsd41: replace
nfserr_resource in pure nfs41 responses

-->Andy

> +
> + =A0 =A0 =A0 fchan->maxresp_cached =3D size + NFSD_MIN_HDR_SEQ_SZ;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -466,9 +492,6 @@ static int init_forechannel_attrs(struct svc_rqst=
 *rqstp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fchan->maxresp_sz =3D maxcount;
> =A0 =A0 =A0 =A0session_fchan->maxresp_sz =3D fchan->maxresp_sz;
>
> - =A0 =A0 =A0 session_fchan->maxresp_cached =3D NFSD_SLOT_CACHE_SIZE;
> - =A0 =A0 =A0 fchan->maxresp_cached =3D session_fchan->maxresp_cached=
;
> -
> =A0 =A0 =A0 =A0/* Use the client's maxops if possible */
> =A0 =A0 =A0 =A0if (fchan->maxops > NFSD_MAX_OPS_PER_COMPOUND)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fchan->maxops =3D NFSD_MAX_OPS_PER_COM=
POUND;
> @@ -478,9 +501,12 @@ static int init_forechannel_attrs(struct svc_rqs=
t *rqstp,
> =A0 =A0 =A0 =A0 * recover pages from existing sessions. For now fail =
session
> =A0 =A0 =A0 =A0 * creation.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 status =3D set_forechannel_maxreqs(fchan);
> + =A0 =A0 =A0 status =3D set_forechannel_drc_size(fchan);
>
> + =A0 =A0 =A0 session_fchan->maxresp_cached =3D fchan->maxresp_cached=
;
> =A0 =A0 =A0 =A0session_fchan->maxreqs =3D fchan->maxreqs;
> +
> + =A0 =A0 =A0 dprintk("%s status %d\n", __func__, status);
> =A0 =A0 =A0 =A0return status;
> =A0}
>
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index fb0c404..ff0b771 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -92,13 +92,17 @@ struct nfs4_cb_conn {
> =A0 =A0 =A0 =A0struct rpc_cred * =A0 =A0 =A0 cb_cred;
> =A0};
>
> -/* Maximum number of slots per session. 128 is useful for long haul =
TCP */
> -#define NFSD_MAX_SLOTS_PER_SESSION =A0 =A0 128
> +/* Maximum number of slots per session. 160 is useful for long haul =
TCP */
> +#define NFSD_MAX_SLOTS_PER_SESSION =A0 =A0 160
> =A0/* Maximum number of pages per slot cache entry */
> =A0#define NFSD_PAGES_PER_SLOT =A0 =A01
> =A0#define NFSD_SLOT_CACHE_SIZE =A0 =A0 =A0 =A0 =A0 PAGE_SIZE
> =A0/* Maximum number of operations per session compound */
> =A0#define NFSD_MAX_OPS_PER_COMPOUND =A0 =A0 =A016
> +/* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
> +#define NFSD_CACHE_SIZE_SLOTS_PER_SESSION =A0 =A0 =A032
> +#define NFSD_MAX_MEM_PER_SESSION =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NF=
SD_SLOT_CACHE_SIZE)
>
> =A0struct nfsd4_cache_entry {
> =A0 =A0 =A0 =A0__be32 =A0 =A0 =A0 =A0 =A0ce_status;
> --
> 1.6.2.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
