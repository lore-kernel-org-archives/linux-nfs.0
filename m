Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50159 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469Ab0DNT62 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 15:58:28 -0400
Received: by gyg13 with SMTP id 13so235810gyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 12:58:27 -0700 (PDT)
In-Reply-To: <1271272729-24422-3-git-send-email-steved@redhat.com>
References: <1271272729-24422-1-git-send-email-steved@redhat.com>
	 <1271272729-24422-3-git-send-email-steved@redhat.com>
Date: Wed, 14 Apr 2010 15:58:26 -0400
Message-ID: <z2j4d569c331004141258y2f16a82ga1aa7826d665b3a9@mail.gmail.com>
Subject: Re: [PATCH 2/3] Try to use kernel function to determine supported
	Kerberos enctypes.
From: Kevin Coffman <kwc@citi.umich.edu>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 14, 2010 at 3:18 PM,  <steved@redhat.com> wrote:
> From: Kevin Coffman <kwc@citi.umich.edu>
>
> This patch replaces a hard-coded list with a function to obtain
> the Kerberos encryption types that the kernel's rpcsec_gss code
> can support.  Defaults to old behavior if kernel does not supply
> information.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/gssd_proc.c |   81 +++++++++++++++++++++++++++++++++++++++++++++++-
>  utils/gssd/krb5_util.c |   16 ++++++++-
>  2 files changed, 94 insertions(+), 3 deletions(-)
>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index be4fb11..12e11d5 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -600,6 +600,67 @@ update_client_list(void)
>        return retval;
>  }
>
> +/* Encryption types supported by the kernel rpcsec_gss code */
> +int num_krb5_enctypes = 0;
> +krb5_enctype *krb5_enctypes = NULL;
> +
> +/*
> + * Parse the supported encryption type information
> + */
> +static int
> +parse_enctypes(char *enctypes)
> +{
> +       int n = 0;
> +       char *curr, *comma;
> +       int i;
> +       static char *cached_types;
> +
> +       if (cached_types && strcmp(cached_types, enctypes) == 0)
> +               return 0;
> +       free(cached_types);
> +
> +       if (krb5_enctypes != NULL) {
> +               free(krb5_enctypes);
> +               krb5_enctypes = NULL;
> +               num_krb5_enctypes = 0;
> +       }
> +
> +       /* count the number of commas */
> +       for (curr = enctypes; curr && *curr != '\0'; curr = ++comma) {
> +               comma = strchr(curr, ',');
> +               if (comma != NULL)
> +                       n++;
> +               else
> +                       break;
> +       }
> +       /* If no more commas and we're not at the end, there's one more value */
> +       if (*curr != '\0')
> +               n++;
> +
> +       /* Empty string, return an error */
> +       if (n == 0)
> +               return ENOENT;
> +
> +       /* Allocate space for enctypes array */
> +       if ((krb5_enctypes = (int *) calloc(n, sizeof(int))) == NULL) {
> +               return ENOMEM;
> +       }
> +
> +       /* Now parse each value into the array */
> +       for (curr = enctypes, i = 0; curr && *curr != '\0'; curr = ++comma) {
> +               krb5_enctypes[i++] = atoi(curr);
> +               comma = strchr(curr, ',');
> +               if (comma == NULL)
> +                       break;
> +       }
> +
> +       num_krb5_enctypes = n;
> +       if (cached_types = malloc(strlen(enctypes)+1))
> +               strcpy(cached_types, enctypes);
> +
> +       return 0;
> +}
> +
>  static int
>  do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
>            gss_buffer_desc *context_token)
> @@ -1128,11 +1189,12 @@ handle_gssd_upcall(struct clnt_info *clp)
>  {
>        uid_t                   uid;
>        char                    *lbuf = NULL;
> -       int                     lbuflen = 0;
> +       int                     lbuflen = 0, code;
>        char                    *p;
>        char                    *mech = NULL;
>        char                    *target = NULL;
>        char                    *service = NULL;
> +       char                    *enctypes = NULL;
>
>        printerr(1, "handling gssd upcall (%s)\n", clp->dirname);
>
> @@ -1176,6 +1238,23 @@ handle_gssd_upcall(struct clnt_info *clp)
>                goto out;
>        }
>
> +       /* read supported encryption types if supplied */
> +       if ((p = strstr(lbuf, "enctypes=")) != NULL) {
> +               enctypes = malloc(lbuflen);
> +               if (!enctypes)
> +                       goto out;
> +               if (sscanf(p, "enctypes=%s", enctypes) != 1) {
> +                       printerr(0, "WARNING: handle_gssd_upcall: "
> +                                   "failed to parse target name "
> +                                   "in upcall string '%s'\n", lbuf);
> +                       goto out;
> +               }
> +               if (parse_enctypes(enctypes) != 0) {
> +                       printerr(0, "WARNING: handle_gssd_upcall: "
> +                               "parsing encryption types failed: errno %d\n", code);
> +               }
> +       }
> +
>        /* read target name */
>        if ((p = strstr(lbuf, "target=")) != NULL) {
>                target = malloc(lbuflen);
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 1c10bd4..0f56b1d 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1274,6 +1274,8 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
>                                    ENCTYPE_DES_CBC_MD5,
>                                    ENCTYPE_DES_CBC_MD4 };
>        int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
> +       extern int num_krb5_enctypes;
> +       extern krb5_enctype *krb5_enctypes;
>
>        /* We only care about getting a krb5 cred */
>        desired_mechs.count = 1;
> @@ -1290,8 +1292,18 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
>                return -1;
>        }
>
> -       maj_stat = gss_set_allowable_enctypes(&min_stat, credh, &krb5oid,
> -                                            num_enctypes, &enctypes);
> +       /*
> +        * If we failed for any reason to produce global
> +        * list of supported enctypes, use local default here.
> +        */
> +       if (krb5_enctypes == NULL)
> +               maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
> +                                       &krb5oid, num_enctypes, &enctypes);
> +       else
> +               maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
> +                                       &krb5oid, num_krb5_enctypes,
> +                                       krb5_enctypes);
> +
>        if (maj_stat != GSS_S_COMPLETE) {
>                pgsserr("gss_set_allowable_enctypes",
>                        maj_stat, min_stat, &krb5oid);
> --

Hi Steve,

The global krb5_enctypes array was used when the list was being read
once from a file.  With the list now coming up with each request in
the updated upcall, I think the list obtained in the upcall should be
added to the clnt_info structure and then passed to the
limit_krb5_enctypes function as a parameter.

K.C.
