From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 1/2] nfsstat.c: Print diff stats every N seconds
Date: Tue, 17 Mar 2009 15:03:37 +1100
Message-ID: <49BF2119.8060600@sgi.com>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:50377 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751312AbZCQD7A (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 16 Mar 2009 23:59:00 -0400
In-Reply-To: <1237225556-27691-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Constantine wrote:
> nfsstat.c: Implemented --sleep[interval] option.
> nfsstat.man: Added information about the --sleep option
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
> ---
>  utils/nfsstat/nfsstat.c   |  158 +++++++++++++++++++++++++++++++++++++--------
>  utils/nfsstat/nfsstat.man |    6 ++-
>  2 files changed, 137 insertions(+), 27 deletions(-)
>
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index 1517414..c25580c 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -167,10 +167,16 @@ DECLARE_SRV(srvinfo, _old);
> @@ -183,6 +189,7 @@ static void		get_stats(const char *, struct statinfo *, int *, int,
> @@ -207,26 +214,29 @@ void usage(char *name)
> @@ -245,7 +255,7 @@ static struct option longopts[] =
> @@ -258,6 +268,7 @@ main(int argc, char **argv)
> @@ -279,7 +290,7 @@ main(int argc, char **argv)
> @@ -311,6 +322,9 @@ main(int argc, char **argv)
> @@ -384,7 +398,7 @@ main(int argc, char **argv)
>   

All good.
> @@ -404,7 +418,33 @@ main(int argc, char **argv)
>  			diff_stats(clientinfo_tmp, clientinfo, 0);
>  		}
>  	}
> +	if(sleep_time) {
> +		while(1) {
> +			if (opt_srv) {
> +				get_stats(NFSSRVSTAT, serverinfo_tmp , &opt_srv, opt_clt, 1);
> +				diff_stats(serverinfo_tmp, serverinfo, 1);
> +			}
> +			if (opt_clt) {
> +				get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
> +				diff_stats(clientinfo_tmp, clientinfo, 0);
> +			}
> +			print_stats_list(opt_prt);
> +			fflush(stdout);
> +
> +			update_old_counters(clientinfo_tmp, clientinfo);
> +			sleep(sleep_time);
> +		}	
> +	} else {
> +		print_server_stats(opt_srv, opt_prt);
> +		print_client_stats(opt_clt, opt_prt);
> +	}
> +
>   
So what I expected to see here, was both the sleep_time != 0 and
sleep_time == 0 cases calling the same function which printed stats in
the old format.  Then the next patch could add the --list option which
added a new feature to that function.  In other words,
print_stats_list() would be introduced in the 2nd patch.

> @@ -479,7 +519,10 @@ main(int argc, char **argv)
> @@ -515,10 +558,43 @@ main(int argc, char **argv)
> @@ -569,6 +645,26 @@ print_callstats(const char *hdr, const char **names,
> @@ -846,3 +942,13 @@ unpause(int sig)
> diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
> index cb5f89f..461b2c0 100644
> --- a/utils/nfsstat/nfsstat.man
> +++ b/utils/nfsstat/nfsstat.man
> @@ -91,7 +91,7 @@ output
>
>   
The manpage change looks fine.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

