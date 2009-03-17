From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 2/2] nfsstat: Add --list flag
Date: Tue, 17 Mar 2009 15:18:00 +1100
Message-ID: <49BF2478.8080600@sgi.com>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com> <1237225556-27691-2-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:49767 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750751AbZCQENV (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2009 00:13:21 -0400
In-Reply-To: <1237225556-27691-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Constantine wrote:
> nfsstat.c: Adds the --list flag to print information in a list format instead of the standard multi-column format
> nfsstat.man: Updates the manpage to include the --list flag.
>
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
> ---
>  utils/nfsstat/nfsstat.c   |   87 ++++++++++++++++++++++++++++++--------------
>  utils/nfsstat/nfsstat.man |    3 ++
>  2 files changed, 62 insertions(+), 28 deletions(-)
>
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index c25580c..51aea8d 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -176,7 +176,7 @@ static void		print_callstats(const char *, const char **,
> @@ -257,6 +257,7 @@ static struct option longopts[] =
> @@ -269,6 +270,7 @@ main(int argc, char **argv)
> @@ -290,7 +292,7 @@ main(int argc, char **argv)
> @@ -348,6 +350,9 @@ main(int argc, char **argv)
Looks good.
> @@ -428,15 +433,24 @@ main(int argc, char **argv)
>  				get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
>  				diff_stats(clientinfo_tmp, clientinfo, 0);
>  			}
> -			print_stats_list(opt_prt);
> +			if (opt_list) {
> +				print_stats_list(opt_prt);
> +			} else {
> +				print_server_stats(opt_srv, opt_prt);
> +				print_client_stats(opt_clt, opt_prt);
> +			}		
>  			fflush(stdout);
>  
>  			update_old_counters(clientinfo_tmp, clientinfo);
>  			sleep(sleep_time);
>  		}	
>  	} else {
> -		print_server_stats(opt_srv, opt_prt);
> -		print_client_stats(opt_clt, opt_prt);
> +		if (opt_list) {
> +			print_stats_list(opt_prt);
> +		} else {
> +			print_server_stats(opt_srv, opt_prt);
> +			print_client_stats(opt_clt, opt_prt);
> +		}
>  	}
>  
>   
The logic is good here.  The code might have been marginally cleaner if
those 6 lines which are now duplicated were pushed into a function.

>  	return 0;
> @@ -568,29 +582,31 @@ print_stats_list(int opt_prt)
> @@ -648,19 +664,34 @@ print_callstats(const char *hdr, const char **names,
>  static void
>  print_callstats_list(const char *hdr, const char **names,
>  		 	unsigned int *srvinfo, unsigned int *cltinfo, 
> -			unsigned int nr)
> +			unsigned int nr, unsigned int nfsvers)
>  {
>  	unsigned long long	srvtotal, clttotal;
>  	int			i;
>  
> -	for (i = 0, srvtotal = 0, clttotal = 0; i < nr; i++) {
> -		srvtotal += srvinfo[i];
> -		clttotal += cltinfo[i];
> -	}
> -	printf("%13s %8s %8s\n", hdr, "Server", "Client");
> -	printf("%12s: %8llu %8llu \n", "total", srvtotal, clttotal);
> -	for (i = 0; i < nr; i++) {
> -			printf("%12s: %8u %8u \n", names[i], srvinfo[i], cltinfo[i]);
> +	if (nfsvers < 4) {
> +		for (i = 0, srvtotal = 0, clttotal = 0; i < nr; i++) {
> +			srvtotal += srvinfo[i];
> +			clttotal += cltinfo[i];
> +		}
> +		printf("%13s %8s %8s\n", hdr, "Server", "Client");
> +		printf("%12s: %8llu %8llu \n", "total", srvtotal, clttotal);
> +		for (i = 0; i < nr; i++) {
> +				printf("%12s: %8u %8u \n", names[i], srvinfo[i], cltinfo[i]);
> +		}
> +	} else {
> +		/* nfsv4's client and server calls aren't named the same, so we'll print them out
> +		*	separately.  Everything will be passed in as srvinfo.  Ignore cltinfo which
> +		*	will be passed in as 0
> +		*/
> +		for (i = 0, srvtotal = 0; i < nr; i++)
> +			srvtotal += srvinfo[i];
> +		printf("%13s %8s\n", hdr, "Calls");
> +		printf("%12s: %8llu \n", "total", srvtotal);
> +		for (i = 0; i < nr; i++) {
> +				printf("%12s: %8u \n", names[i], srvinfo[i]);
> +		}
> +		printf("\n");
>  	}
>   

Maybe you can smooth out this difference, and make the code simpler and
cleaner, by making the output always be exactly two columns, one for the
label and one for the value.  Then your earlier quoted example would be
something like

       nfs v3 client total:   213
        nfs v3 client null:     0
     nfs v3 client getattr:    23
     nfs v3 client setattr:     9
      nfs v3 client lookup:     8
      nfs v3 client access:     1
    nfs v3 client readlink:     0
        nfs v3 client read:     7
       nfs v3 client write:    23
      nfs v3 client create:     8
       nfs v3 client mkdir:     0
     nfs v3 client symlink:     0
       nfs v3 client mknod:     0
      nfs v3 client remove:     7
       nfs v3 client rmdir:     0
      nfs v3 client rename:     1
        nfs v3 client link:     0
     nfs v3 client readdir:     0
 nfs v3 client readdirplus:     0
      nfs v3 client fsstat:   126
      nfs v3 client fsinfo:     0
    nfs v3 client pathconf:     0
      nfs v3 client commit:     0 
       nfs v3 server total:     0
        nfs v3 server null:     0
     nfs v3 server getattr:     0
     nfs v3 server setattr:     0
      nfs v3 server lookup:     0
      nfs v3 server access:     0
    nfs v3 server readlink:     0
        nfs v3 server read:     0
       nfs v3 server write:     0
      nfs v3 server create:     0
       nfs v3 server mkdir:     0
     nfs v3 server symlink:     0
       nfs v3 server mknod:     0
      nfs v3 server remove:     0
       nfs v3 server rmdir:     0
      nfs v3 server rename:     0
        nfs v3 server link:     0
     nfs v3 server readdir:     0
 nfs v3 server readdirplus:     0
      nfs v3 server fsstat:     0
      nfs v3 server fsinfo:     0
    nfs v3 server pathconf:     0
      nfs v3 server commit:     0


Instead of

nfs v3 stats:   Server   Client
       total:        0      213
        null:        0        0
     getattr:        0       23
     setattr:        0        9
      lookup:        0        8
      access:        0        1
    readlink:        0        0
        read:        0        7
       write:        0       23
      create:        0        8
       mkdir:        0        0
     symlink:        0        0
       mknod:        0        0
      remove:        0        7
       rmdir:        0        0
      rename:        0        1
        link:        0        0
     readdir:        0        0
 readdirplus:        0        0
      fsstat:        0      126
      fsinfo:        0        0
    pathconf:        0        0
      commit:        0        0 


This would also help with your stated objective of being to grep the output.
>  		
>  }
> diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
> index 461b2c0..52215a9 100644
> --- a/utils/nfsstat/nfsstat.man
> +++ b/utils/nfsstat/nfsstat.man
> @@ -72,6 +72,9 @@ Display all of the above facilities.
>
>   
Looks good.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

