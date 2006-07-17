From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Heimdal compile error
Date: Mon, 17 Jul 2006 09:25:20 -0400
Message-ID: <4d569c330607170625t7b83e29ahe7e489cbe2a2decf@mail.gmail.com>
References: <200607171049.31126.mario-fetka@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2T6E-0005Yh-9p
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 06:25:26 -0700
Received: from nf-out-0910.google.com ([64.233.182.184])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2T6B-0005pZ-4m
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 06:25:26 -0700
Received: by nf-out-0910.google.com with SMTP id m19so488392nfc
	for <nfs@lists.sourceforge.net>; Mon, 17 Jul 2006 06:25:21 -0700 (PDT)
To: "Mario Fetka" <mario-fetka@gmx.at>
In-Reply-To: <200607171049.31126.mario-fetka@gmx.at>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Thanks.  What version of Heimdal is this against?

I haven't had time to test against heimdal since the libgssapi change.
 Does the code work after you get it built?

K.C.

On 7/17/06, Mario Fetka <mario-fetka@gmx.at> wrote:
> the following patch corrects the error.
>
> diff -urN nfs-utils-1.0.7.org/utils/gssd/context_heimdal.c
> nfs-utils-1.0.7/utils/gssd/context_heimdal.c
> --- nfs-utils-1.0.7.org/utils/gssd/context_heimdal.c    2005-07-10
> 12:14:01.526867000 +0200
> +++ nfs-utils-1.0.7/utils/gssd/context_heimdal.c        2005-07-10
> 12:14:32.815110736 +0200
> @@ -46,6 +46,20 @@
>  #include "gss_oids.h"
>  #include "write_bytes.h"
>
> +typedef struct gss_ctx_id_t_desc_struct {
> +  struct krb5_auth_context_data *auth_context;
> +  gss_name_t source, target;
> +  OM_uint32 flags;
> +  enum { LOCAL = 1, OPEN = 2,
> +         COMPAT_OLD_DES3 = 4,
> +         COMPAT_OLD_DES3_SELECTED = 8,
> +  } more_flags;
> +  struct krb5_ticket *ticket;
> +  OM_uint32 lifetime;
> +  pthread_mutex_t ctx_id_mutex;
> +  struct gss_msg_order *order;
> +} gss_ctx_id_t_desc;
> +
>  #define MAX_CTX_LEN 4096
>
>  int write_heimdal_keyblock(char **p, char *end, krb5_keyblock *key)
>
> wfg
> Mario
>
>
>
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
