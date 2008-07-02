From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [Patch] enable preferred realms for ccache searching
Date: Wed, 2 Jul 2008 11:53:12 -0400
Message-ID: <4d569c330807020853m37a834ex5ba191faf85b0f97@mail.gmail.com>
References: <20080624153524.GK4484@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "Lukas Hejtmanek" <xhejtman@ics.muni.cz>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080624153524.GK4484@ics.muni.cz>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Lukas,
I'm fixing some things up in this patch (see comments below) and I
have a question as well:  Is "score" ever anything besides zero or
one?  I can see how it might be used in the future for including more
preferences, but today it is only zero or one?

Thanks,
K.C.

On Tue, Jun 24, 2008 at 11:35 AM, Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
>
> The rpc.gssd scans for any suitable kerberos ticket. In cross-realm
> environment this would not have to be the desired behaviour. Therefore a new
> option is presented -R preferred realm so that the rpc.gssd preferrs tickets
> from this realm. By default, no realm is preferred so we follow the original
> behavior.
>
> Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
>
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index ff5a454..c7f9bdd 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -61,6 +61,7 @@ char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
>  int  use_memcache = 0;
>  int  root_uses_machine_creds = 1;
>  int  ccache_timeout = 0;
> +char *preferred_realm = NULL;
>
>  void
>  sig_die(int signal)
> @@ -83,7 +84,7 @@ sig_hup(int signal)
>  static void
>  usage(char *progname)
>  {
> -       fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout]\n",
> +       fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
>                progname);
>        exit(1);
>  }
> @@ -100,7 +101,7 @@ main(int argc, char *argv[])
>        char *progname;
>
>        memset(ccachesearch, 0, sizeof(ccachesearch));
> -       while ((opt = getopt(argc, argv, "fvrmnMp:k:d:t:")) != -1) {
> +       while ((opt = getopt(argc, argv, "fvrmnMp:k:d:t:R:")) != -1) {
>                switch (opt) {
>                        case 'f':
>                                fg = 1;
> @@ -138,6 +139,9 @@ main(int argc, char *argv[])
>                        case 't':
>                                ccache_timeout = atoi(optarg);
>                                break;
> +                       case 'R':
> +                               preferred_realm = strdup(optarg);
> +                               break;
>                        default:
>                                usage(argv[0]);
>                                break;
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 6dd57bf..ebabc3b 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -66,6 +66,7 @@ extern char                   *ccachesearch[];
>  extern int                     use_memcache;
>  extern int                     root_uses_machine_creds;
>  extern int                     ccache_timeout;
> +extern char                    *preferred_realm;
>
>  TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
>
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index 81ea68d..e097641 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -86,6 +86,9 @@ Increases the verbosity of the output (can be specified multiple times).
>  .B -r
>  If the rpcsec_gss library supports setting debug level,
>  increases the verbosity of the output (can be specified multiple times).
> +.B -R realm
> +Tickets from this realm will be preffered when scaning ccache dir.

I'm fixing typo here.

> +By default no realm is preferred.
>  .TP
>  .B -t timeout
>  Timeout in seconds for kernel tickets cache. This is workaround in case you want to
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 512c1cf..983fb2c 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -135,7 +135,7 @@ static int gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
>                struct dirent **d);
>  static int gssd_get_single_krb5_cred(krb5_context context,
>                krb5_keytab kt, struct gssd_k5_kt_princ *ple);
> -
> +static int query_krb5_ccache(const char* cred_cache, char **ret_princname, char **ret_realm);
>
>  /*
>  * Called from the scandir function to weed out potential krb5
> @@ -179,6 +179,10 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
>        int found = 0;
>        struct dirent *best_match_dir = NULL;
>        struct stat best_match_stat, tmp_stat;
> +       char buf[1030];
> +       char *princname;
> +       char *realm = NULL;
> +       int score, best_match_score = 0;
>
>        memset(&best_match_stat, 0, sizeof(best_match_stat));
>        *d = NULL;
> @@ -194,6 +198,8 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
>                                 namelist[i]->d_name);
>                        snprintf(statname, sizeof(statname),
>                                 "%s/%s", dirname, namelist[i]->d_name);
> +                       snprintf(buf, sizeof(buf), "FILE:%s/%s", dirname,
> +                                       namelist[i]->d_name);
>                        if (lstat(statname, &tmp_stat)) {
>                                printerr(0, "Error doing stat on file '%s'\n",
>                                         statname);
> @@ -213,9 +219,19 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
>                                free(namelist[i]);
>                                continue;
>                        }
> -                       printerr(3, "CC file '%s' matches owner check and has "
> -                                "mtime of %u\n",
> -                                namelist[i]->d_name, tmp_stat.st_mtime);
> +                       if (!query_krb5_ccache(buf, &princname, &realm)) {
> +                               printerr(3, "CC file '%s' expired or corrupt\n", statname);
> +                               continue;
> +                       }
> +
> +                       score = 0;
> +                       if (preferred_realm && !strcmp(realm, preferred_realm))
> +                               score+=1;
> +
> +                       printerr(3, "CC file '%s'(%s@%s) passed all checks and"
> +                                   " has mtime of %u\n",
> +                                namelist[i]->d_name, princname, realm,
> +                                tmp_stat.st_mtime);
>                        /*
>                         * if more than one match is found, return the most
>                         * recent (the one with the latest mtime), and
> @@ -224,20 +240,26 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
>                        if (!found) {
>                                best_match_dir = namelist[i];
>                                best_match_stat = tmp_stat;
> +                               best_match_score = score;
>                                found++;
>                        }
>                        else {
>                                /*
> -                                * If the current match has an mtime later
> +                                * If current score is higher than best match
> +                                * score, we use the current match. Otherwies,
> +                                * if the current match has an mtime later
>                                 * than the one we are looking at, then use
>                                 * the current match.  Otherwise, we still
>                                 * have the best match.
>                                 */
> -                               if (tmp_stat.st_mtime >
> -                                           best_match_stat.st_mtime) {
> +                               if (best_match_score < score ||
> +                                   (best_match_score == score &&
> +                                      tmp_stat.st_mtime >
> +                                           best_match_stat.st_mtime)) {
>                                        free(best_match_dir);
>                                        best_match_dir = namelist[i];
>                                        best_match_stat = tmp_stat;
> +                                       best_match_score = score;
>                                }
>                                else {
>                                        free(namelist[i]);
> @@ -248,6 +270,8 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname, struct dirent **d)
>                                         best_match_dir->d_name,
>                                         best_match_stat.st_mtime);
>                        }
> +                       free(princname);
> +                       free(realm);
>                }
>                free(namelist);
>        }
> @@ -884,6 +908,82 @@ out:
>        return retval;
>  }
>
> +
> +static int
> +check_for_tgt (krb5_context context, krb5_ccache ccache,
> +               krb5_principal principal)
> +{
> +       krb5_error_code ret;
> +       krb5_creds creds;
> +       krb5_cc_cursor cur;
> +       int found = 0;
> +
> +       ret = krb5_cc_start_seq_get(context, ccache, &cur);
> +       if (ret)
> +               return 0;
> +
> +       while (!found && !(ret = krb5_cc_next_cred(context, ccache, &cur, &creds))) {
> +               if (creds.server->length == 2 &&
> +                               strcmp(creds.server->realm.data,
> +                                       principal->realm.data) == 0 &&
> +                               strcmp((char *)creds.server->data[0].data,
> +                                       "krbtgt") == 0 &&
> +                               strcmp((char *)creds.server->data[1].data,
> +                                       principal->realm.data) == 0 &&

I don't believe these creds strings are guaranteed to be null-terminated.

> +                               creds.times.endtime > time(NULL))
> +                       found = 1;
> +               krb5_free_cred_contents(context, &creds);
> +       }
> +       if (ret == KRB5_CC_END) {
> +               krb5_cc_end_seq_get(context, ccache, &cur);
> +       }
> +
> +       return found;
> +}
> +
> +static
> +int query_krb5_ccache(const char* cred_cache, char **ret_princname, char **ret_realm)
> +{
> +       krb5_error_code ret;
> +       krb5_context context;
> +       krb5_ccache ccache;
> +       krb5_principal principal;
> +       int found = 0;
> +       char *str = NULL;
> +
> +       ret = krb5_init_context (&context);
> +       if (ret)
> +               return 0;
> +
> +       if(!cred_cache || krb5_cc_resolve(context, cred_cache, &ccache))
> +               goto err_cache;
> +
> +       if (krb5_cc_set_flags(context, ccache, 0))
> +               goto err_princ;
> +
> +       ret = krb5_cc_get_principal (context, ccache, &principal);
> +       if (ret)
> +               goto err_princ;
> +
> +       found = check_for_tgt (context, ccache, principal);
> +       if (found) {
> +               ret = krb5_unparse_name (context, principal, ret_princname);

This storage should be freed with krb5_free_unparsed_name(), it is
being freed with free above.

> +               if (!ret && (str = strchr(*ret_princname, '@'))) {
> +                       *str = '\0';
> +                       *ret_realm = strdup(str+1);
> +               } else{
> +                       found = 0;
> +               }
> +       }
> +       krb5_free_principal (context, principal);
> +err_princ:
> +       krb5_cc_set_flags(context, ccache,  KRB5_TC_OPENCLOSE);
> +       krb5_cc_close (context, ccache);
> +err_cache:
> +       krb5_free_context (context);
> +       return found;
> +}
> +
>  /*==========================*/
>  /*===  External routines ===*/
>  /*==========================*/
>
>
