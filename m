Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbaCKTRe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 15:17:34 -0400
Message-ID: <531F6146.2060807@RedHat.com>
Date: Tue, 11 Mar 2014 15:17:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: jonathan.dascenzo@netapp.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix tlock.c to use sigaction() over deprecated signal().
 Fixes sync issues when client is loaded. (Particularly test12)
References: <1393268734-23325-1-git-send-email-jonathan.dascenzo@netapp.com>
In-Reply-To: <1393268734-23325-1-git-send-email-jonathan.dascenzo@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/24/2014 02:05 PM, jonathan.dascenzo@netapp.com wrote:
> From: Jonathan Dascenzo <Jonathan.Dascenzo@netapp.com>
> 
> ---
>  lock/tlock.c |   30 ++++++++++++++++++++++--------
>  1 file changed, 22 insertions(+), 8 deletions(-)
Committed....

steved.

> 
> diff --git a/lock/tlock.c b/lock/tlock.c
> index 8a7d0cc..39a6ad9 100644
> --- a/lock/tlock.c
> +++ b/lock/tlock.c
> @@ -272,20 +272,24 @@ testexit(nok)
>  	int nok;
>  {
>  
> +	struct sigaction act;
>  	close_testfile(DO_UNLINK);
>  	if (nok) {
>  		testreport(1);
>  	}
>  	if (who == PARENT) {
> -		signal(SIGCLD, SIG_DFL);
> +		act.sa_handler = SIG_DFL;
> +		sigaction(SIGCLD, &act, NULL);
>  		if (nok) {
> -			signal(SIGINT, SIG_IGN);
> +			act.sa_handler = SIG_IGN;
> +			sigaction(SIGINT, &act, NULL);
>  			kill(childpid, SIGINT);
>  		}
>  		wait((int *)0);
>  	} else {
>  		if (nok) {
> -			signal(SIGINT, SIG_IGN);
> +			act.sa_handler = SIG_IGN;
> +			sigaction(SIGINT, &act, NULL);
>  			kill(parentpid, SIGINT);
>  		}
>  	}
> @@ -1450,7 +1454,9 @@ test12()
>  			close_testfile(DO_UNLINK);
>  		} else {
>  			/* subchild */
> -			signal(SIGINT, SIG_DFL);
> +			struct sigaction act;
> +			act.sa_handler = SIG_DFL;
> +			sigaction(SIGINT, &act, NULL);
>  			test(12, 0, F_TLOCK, (off_t)0, (off_t)0, PASS, FATAL);
>  			for (;;)
>  				sleep(1);
> @@ -1667,13 +1673,19 @@ main(argc, argv)
>  	/*
>  	 * Fork child...
>  	 */
> +	struct sigaction act; 
> +	act.sa_handler = SIG_DFL;
>  	if ((childpid = fork()) == 0) {
>  		who = CHILD;
> -		signal(SIGINT, parentsig);
> +		sigaction(SIGINT, &act, NULL);
> +		act.sa_handler = parentsig;
> +		sigaction(SIGINT, &act, NULL);
>  	} else {
>  		who = PARENT;
> -		signal(SIGINT, childsig);
> -		signal(SIGCLD, childdied);
> +		act.sa_handler = childsig;
> +		sigaction(SIGINT, &act, NULL);
> +		act.sa_handler = childdied;
> +		sigaction(SIGCLD, &act, NULL);
>  	}
>  
>  	/*
> @@ -1692,7 +1704,9 @@ main(argc, argv)
>  	if (who == CHILD) {
>  		childwait();
>  	} else {
> -		signal(SIGCLD, SIG_DFL);
> +		struct sigaction;
> +		act.sa_handler = SIG_DFL;
> +		sigaction(SIGCLD, &act, NULL);
>  		childfree(0);
>  	}
>  	testexit(0);
> 
