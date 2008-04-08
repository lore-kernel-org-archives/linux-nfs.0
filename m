From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH] gssd: search multiple directories for credentials
Date: Tue, 8 Apr 2008 13:15:05 -0400
Message-ID: <4d569c330804081015g7db0c3f7oe7784784a2e0fc40@mail.gmail.com>
References: <20080407214228.GA11350@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Vince Busam" <vbusam@google.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:1688 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbYDHRPJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 13:15:09 -0400
Received: by ti-out-0910.google.com with SMTP id 28so820380tif.23
        for <linux-nfs@vger.kernel.org>; Tue, 08 Apr 2008 10:15:07 -0700 (PDT)
In-Reply-To: <20080407214228.GA11350@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 7, 2008 at 5:42 PM, Vince Busam <vbusam@google.com> wrote:
> We store kerberos credentials in multiple places, and it would be nice to
>  search them for a valid credential when making NFS requests.  This patch
>  allows that.
>
>  diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd.c nfs-utils-1.1.1/utils/gssd/gssd.c
>  --- nfs-utils-1.1.1.orig/utils/gssd/gssd.c      2007-10-18 20:07:28.000000000 -0700
>  +++ nfs-utils-1.1.1/utils/gssd/gssd.c   2008-03-17 13:35:39.000000000 -0700
>  @@ -57,6 +57,7 @@ char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_
>   char pipefs_nfsdir[PATH_MAX] = GSSD_PIPEFS_DIR;
>   char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
>   char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR;
>  +char *ccachesearch[GSSD_MAX_CCACHE_SEARCH];
>   int  use_memcache = 0;
>   int  root_uses_machine_creds = 1;
>
>  @@ -93,9 +94,11 @@ main(int argc, char *argv[])
>         int verbosity = 0;
>         int rpc_verbosity = 0;
>         int opt;
>  +       int i;
>         extern char *optarg;
>         char *progname;
>
>  +       memset(ccachesearch, 0, sizeof(ccachesearch));
>         while ((opt = getopt(argc, argv, "fvrmnMp:k:d:")) != -1) {
>                 switch (opt) {
>                         case 'f':
>  @@ -130,6 +133,12 @@ main(int argc, char *argv[])
>                                 strncpy(ccachedir, optarg, sizeof(ccachedir));
>                                 if (ccachedir[sizeof(ccachedir)-1] != '\0')
>                                         errx(1, "ccachedir path name too long");
>  +                               i = 0;
>  +                               strtok(ccachedir,":");
>  +                               do {
>  +                                       ccachesearch[i] = strtok(NULL,":");
>  +                                       i++;
>  +                               } while (ccachesearch[i-1] && (i<(GSSD_MAX_CCACHE_SEARCH-1)));
>                                 break;
>                         default:
>                                 usage(argv[0]);
>  diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd.h nfs-utils-1.1.1/utils/gssd/gssd.h
>  --- nfs-utils-1.1.1.orig/utils/gssd/gssd.h      2007-10-18 20:07:28.000000000 -0700
>  +++ nfs-utils-1.1.1/utils/gssd/gssd.h   2008-03-12 13:10:19.000000000 -0700
>  @@ -50,6 +50,7 @@
>   #define GSSD_DEFAULT_KEYTAB_FILE               "/etc/krb5.keytab"
>   #define GSSD_SERVICE_NAME                      "nfs"
>   #define GSSD_SERVICE_NAME_LEN                  3
>  +#define GSSD_MAX_CCACHE_SEARCH                 16
>
>   /*
>   * The gss mechanisms that we can handle
>  @@ -62,6 +63,7 @@ extern char                   pipefs_dir[PATH_MAX];
>   extern char                    pipefs_nfsdir[PATH_MAX];
>   extern char                    keytabfile[PATH_MAX];
>   extern char                    ccachedir[PATH_MAX];
>  +extern char                    *ccachesearch[GSSD_MAX_CCACHE_SEARCH];
>   extern int                     use_memcache;
>   extern int                     root_uses_machine_creds;
>
>  diff -up --recursive nfs-utils-1.1.1.orig/utils/gssd/gssd_proc.c nfs-utils-1.1.1/utils/gssd/gssd_proc.c
>  --- nfs-utils-1.1.1.orig/utils/gssd/gssd_proc.c 2007-10-18 20:07:28.000000000 -0700
>  +++ nfs-utils-1.1.1/utils/gssd/gssd_proc.c      2008-03-12 14:44:26.000000000 -0700
>  @@ -691,10 +691,18 @@ handle_krb5_upcall(struct clnt_info *clp
>
>         if (uid != 0 || (uid == 0 && root_uses_machine_creds == 0)) {
>                 /* Tell krb5 gss which credentials cache to use */
>  -               gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
>  +               gssd_setup_krb5_user_gss_ccache(uid, clp->servername, ccachedir);
>
>                 create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
>                                                      AUTHTYPE_KRB5);
>  +               for (ccname = ccachesearch; *ccname; ccname++) {
>  +                       gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *ccname);
>  +
>  +                       create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
>  +                                                            AUTHTYPE_KRB5);
>  +                       if (create_resp == 0)
>  +                               break;
>  +               }
>         }

Thanks for the patch, and sorry for taking so long to get to it.

If I use "-d /tmp:/tmp/ticket:/tmp/tickets", this part ignores the
fact that I've successfully created the context with credentials in
/tmp and continues to try /tmp/ticket and /tmp/tickets and eventually
fails.

I think I see why you continued to use ccachedir as well as
ccachesearch, but I'm not happy with it.  I'm reworking this and will
submit upstream.

K.C.
