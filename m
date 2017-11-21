Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47873 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751187AbdKURDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Nov 2017 12:03:25 -0500
Subject: Re: [RFC PATCH] rpc.svcgssd: add ability to override hostname
To: Leigh Brown <leigh@solinno.co.uk>, linux-nfs@vger.kernel.org
References: <93e03b4df2fecbc505547d80935d5be7@doppler.thel33t.co.uk>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d3c18083-685f-9cee-73b3-7cad2fbe27c2@RedHat.com>
Date: Tue, 21 Nov 2017 12:03:22 -0500
MIME-Version: 1.0
In-Reply-To: <93e03b4df2fecbc505547d80935d5be7@doppler.thel33t.co.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 11/20/2017 09:27 AM, Leigh Brown wrote:
> Add the -h option to rpc.svcgssd to allow the hostname to be overridden.
> This is useful in clustered configurations using NVSv4 and Kerberos to
> ensure the hostname is set to the service name of the cluster.
A couple things... 

1) The patch did not apply for krb5_util.c or svcgssd.c. Not
    clear why.. but they didn't
2) The patch cause a "implicit declaration of function" 
   warning because the new routines were not added to gss_util.h
3) Since the return value of gssd_sethostname() is never checked
   why not make it void and log an warning when something
   goes wrong.

Finally, adding a command line argument is always a touchy thing,
supporting unnecessary flags is the last thing we want to do. So..
Please give me an example how this will be used, I know you say in
a cluster configuration, but what does that mean... A little
context please. Also is there any around not adding this flag
and achieving the same results.

I'm not totally against adding this flag I just want to
investigate all avenues..

steved.  
> 
> Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
> ---
>  systemd/nfs.conf.man   |  4 +++-
>  utils/gssd/gss_util.c  | 21 +++++++++++++++++++++
>  utils/gssd/krb5_util.c |  2 +-
>  utils/gssd/svcgssd.c   | 14 ++++++++++++--
>  utils/gssd/svcgssd.man | 10 +++++++++-
>  5 files changed, 46 insertions(+), 5 deletions(-)
> 
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index 189b052..08ca8c2 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -228,7 +228,9 @@ for details.
>  .TP
>  .B svcgssd
>  Recognized values:
> -.BR principal .
> +.BR principal
> +and
> +.BR hostname .
> 
>  See
>  .BR rpc.svcgssd (8)
> diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
> index 2e6d40f..9966a06 100644
> --- a/utils/gssd/gss_util.c
> +++ b/utils/gssd/gss_util.c
> @@ -339,3 +339,24 @@ out:
>      return retval;
>  }
> 
> +static char *gssd_hostname = NULL;
> +
> +int gssd_gethostname(char *name, size_t len)
> +{
> +    if (gssd_hostname) {
> +        strncpy(name, gssd_hostname, len);
> +        return 0;
> +    }
> +    else
> +        return gethostname(name, len);
> +}
> +
> +/* NB: Different semantics to sethostname(2) */
> +int gssd_sethostname(const char *name)
> +{
> +    if (gssd_hostname)
> +        free(gssd_hostname);
> +
> +    gssd_hostname = strdup(name);
> +    return gssd_hostname ? 0 : ENOMEM;
> +}
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index b64818a..a9b84ee 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -785,7 +785,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>          goto out;
> 
>      /* Get full local hostname */
> -    if (gethostname(myhostname, sizeof(myhostname)) == -1) {
> +    if (gssd_gethostname(myhostname, sizeof(myhostname)) == -1) {
>          retval = errno;
>          k5err = gssd_k5_err_msg(context, retval);
>          printerr(1, "%s while getting local hostname\n", k5err);
> diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
> index 3514ae1..62f8973 100644
> --- a/utils/gssd/svcgssd.c
> +++ b/utils/gssd/svcgssd.c
> @@ -82,7 +82,8 @@ sig_hup(int signal)
>  static void
>  usage(char *progname)
>  {
> -    fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal]\n",
> +    fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-h hostname] "
> +                               "[-p principal]\n",
>          progname);
>      exit(1);
>  }
> @@ -111,7 +112,13 @@ main(int argc, char *argv[])
>      else
>          principal = s;
> 
> -    while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
> +    s = conf_get_str("svcgssd", "hostname");
> +    if (!s)
> +        ;
> +    else
> +        gssd_sethostname(s);
> +
> +    while ((opt = getopt(argc, argv, "fivrnp:h:")) != -1) {
>          switch (opt) {
>              case 'f':
>                  fg = 1;
> @@ -131,6 +138,9 @@ main(int argc, char *argv[])
>              case 'p':
>                  principal = optarg;
>                  break;
> +            case 'h':
> +                gssd_sethostname(optarg);
> +                break;
>              default:
>                  usage(argv[0]);
>                  break;
> diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
> index 15ef4c9..744cab7 100644
> --- a/utils/gssd/svcgssd.man
> +++ b/utils/gssd/svcgssd.man
> @@ -6,7 +6,7 @@
>  .SH NAME
>  rpc.svcgssd \- server-side rpcsec_gss daemon
>  .SH SYNOPSIS
> -.B "rpc.svcgssd [-n] [-v] [-r] [-i] [-f] [-p principal]"
> +.B "rpc.svcgssd [-n] [-v] [-r] [-i] [-f] [-h hostname] [-p principal]"
>  .SH DESCRIPTION
>  The rpcsec_gss protocol gives a means of using the gss-api generic security
>  api to provide security for protocols using rpc (in particular, nfs).  Before
> @@ -36,6 +36,9 @@ increases the verbosity of the output (can be specified multiple times).
>  If the nfsidmap library supports setting debug level,
>  increases the verbosity of the output (can be specified multiple times).
>  .TP
> +.B -h
> +Use \fIhostname\fR instead of the default hostname.
> +.TP
>  .B -p
>  Use \fIprincipal\fR instead of the default
>  .RI nfs/ FQDN @ REALM .
> @@ -61,6 +64,11 @@ this is equivalent to the
>  option.  If set to any other value, that is used like the
>  .B -p
>  option.
> +.TP
> +.B hostname
> +This is equivalent to the
> +.B -h
> +option.
> 
>  .SH SEE ALSO
>  .BR rpc.gssd(8),
