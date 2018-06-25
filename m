Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751891AbeFYPhb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:37:31 -0400
Subject: Re: [PATCH] nfs-utils: Spelling fixes
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: calum.mackay@oracle.com
References: <1529660470.7576.3.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <489d8ca6-5072-4f8c-e9f6-0d3d69ae5e83@RedHat.com>
Date: Mon, 25 Jun 2018 11:37:29 -0400
MIME-Version: 1.0
In-Reply-To: <1529660470.7576.3.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/22/2018 05:41 AM, Justin Mitchell wrote:
> Fix some typos in the nfs.conf related code
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Committed... 

steved.

> ---
>  support/nfs/conffile.c     | 2 +-
>  tools/nfsconf/nfsconf.man  | 4 ++--
>  tools/nfsconf/nfsconfcli.c | 6 +++---
>  3 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 4e5cf9d..3845b94 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -640,7 +640,7 @@ conf_get_num(const char *section, const char *tag, int def)
>  /*
>   * Return the Boolean value denoted by TAG in section SECTION, or DEF
>   * if that tags does not exist.
> - * FALSE is returned for case-insensitve comparisons with 0, f, false, n, no, off
> + * FALSE is returned for case-insensitive comparisons with 0, f, false, n, no, off
>   * TRUE is returned for 1, t, true, y, yes, on
>   * A failure to match one of these results in DEF
>   */
> diff --git a/tools/nfsconf/nfsconf.man b/tools/nfsconf/nfsconf.man
> index 197caae..1ae8543 100644
> --- a/tools/nfsconf/nfsconf.man
> +++ b/tools/nfsconf/nfsconf.man
> @@ -79,7 +79,7 @@ Select a different config file to operate upon, default is
>  Select a specific sub-section
>  .SH EXIT STATUS
>  .SS \fB\-\-isset\fR mode
> -In this mode the command will return success (0) if the selected tag has a value, any other exit code indicates the value is not set, or some other error has occured.
> +In this mode the command will return success (0) if the selected tag has a value, any other exit code indicates the value is not set, or some other error has occurred.
>  .SS all other modes
>  Success is indicated by an exit status of zero, any other status indicates an error. Error messages are output on stderr, and increasing verbosity will give more detailed explanations if any are available.
>  .SH EXAMPLES
> @@ -87,7 +87,7 @@ Success is indicated by an exit status of zero, any other status indicates an er
>  .B nfsconf -v --dump --file /tmp/testconf.conf  sorted.conf
>  Check a new config file for syntax errors and output a sorted version for ease of comparison with existing settings.
>  .TP
> -.B if ! nfsconf --isset gssd preferred-realm ; then echo 'No prefered realm configured for gss'; fi
> +.B if ! nfsconf --isset gssd preferred-realm ; then echo 'No preferred realm configured for gss'; fi
>  The tool allows for easy testing of configuration values from shell scripts, here we test if a specific value has been set.
>  .TP
>  .B nfsconf --file /etc/nfsmount.conf --get --arg /home MountPoint background
> diff --git a/tools/nfsconf/nfsconfcli.c b/tools/nfsconf/nfsconfcli.c
> index b5cb132..f98d0d1 100644
> --- a/tools/nfsconf/nfsconfcli.c
> +++ b/tools/nfsconf/nfsconfcli.c
> @@ -69,7 +69,7 @@ int main(int argc, char **argv)
>  			case 0:
>  				break;
>  			case 'f':
> -				/* user specified souce path for config */
> +				/* user specified source path for config */
>  				confpath = optarg;
>  				break;
>  			case 'a':
> @@ -110,7 +110,7 @@ int main(int argc, char **argv)
>  		xlog_config(D_ALL, 1);
>  	xlog_stderr(1);
>  	xlog_syslog(0);
> -	xlog_open("nfsconftool");
> +	xlog_open("nfsconf");
>  
>  	if (mode == MODE_NONE) {
>  		fprintf(stderr, "Error: No MODE selected.\n");
> @@ -223,7 +223,7 @@ int main(int argc, char **argv)
>  			ret = 1;
>  		}
>  	} else {
> -		fprintf(stderr, "Mode not yet implimented.\n");
> +		fprintf(stderr, "Mode not yet implemented.\n");
>  		ret = 2;
>  	}
>  
> 
