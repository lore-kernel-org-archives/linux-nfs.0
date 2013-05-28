Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752548Ab3E1SlB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 14:41:01 -0400
Message-ID: <51A4FA3A.1080805@RedHat.com>
Date: Tue, 28 May 2013 14:40:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
References: <1366380998-2581-1-git-send-email-steved@redhat.com> <20130502131332.5c0ce2b0@notabene.brown>
In-Reply-To: <20130502131332.5c0ce2b0@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/05/13 23:13, NeilBrown wrote:
> Subject: Fix recent fix to Avoid DNS reverse resolution in gssd.
> 
> The final version for this fix that was committed inverted the test
> so makes no change in the important cases.
> The documentation didn't really help a naive user know when the new -D flag
> should be used.
> And the code (once fixed) avoided DNS resolution on non-qualified names too,
> which probably isn't a good idea.
> 
> This patch fixes all three issues.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed....

steved.

> 
> 
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index 1df75c5..ac13fd4 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -195,11 +195,28 @@ option when starting
>  .BR rpc.gssd .
>  .SH OPTIONS
>  .TP
> -.B -D
> -DNS Reverse lookups are not used for determining the
> -server names pass to GSSAPI. This option will reverses that and forces 
> -the use of DNS Reverse resolution of the server's IP address to 
> -retrieve the server name to use in GSAPI authentication.
> +.B \-D
> +The server name passed to GSSAPI for authentication is normally the
> +name exactly as requested.  e.g. for NFS
> +it is the server name in the "servername:/path" mount request.  Only if this
> +servername appears to be an IP address (IPv4 or IPv6) or an
> +unqualified name (no dots) will a reverse DNS lookup
> +will be performed to get the canoncial server name.
> +
> +If
> +.B \-D
> +is present, a reverse DNS lookup will
> +.I always
> +be used, even if the server name looks like a canonical name.  So it
> +is needed if partially qualified, or non canonical names are regularly
> +used.
> +
> +Using
> +.B \-D
> +can introduce a security vulnerability, so it is recommended that
> +.B \-D
> +not be used, and that canonical names always be used when requesting
> +services.
>  .TP
>  .B -f
>  Runs
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index af1844c..d381664 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -176,7 +176,6 @@ get_servername(const char *name, const struct sockaddr *sa, const char *addr)
>  	char			*hostname;
>  	char			hbuf[NI_MAXHOST];
>  	unsigned char		buf[sizeof(struct in6_addr)];
> -	int			servername = 0;
>  
>  	if (avoid_dns) {
>  		/*
> @@ -184,15 +183,18 @@ get_servername(const char *name, const struct sockaddr *sa, const char *addr)
>  		 * If it is an IP address, do the DNS lookup otherwise
>  		 * skip the DNS lookup.
>  		 */
> -		servername = 0;
> -		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) == 1)
> -			servername = 1; /* IPv4 */
> -		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) == 1)
> -			servername = 1; /* or IPv6 */
> -
> -		if (servername) {
> +		int is_fqdn = 1;
> +		if (strchr(name, '.') == NULL)
> +			is_fqdn = 0; /* local name */
> +		else if (inet_pton(AF_INET, name, buf) == 1)
> +			is_fqdn = 0; /* IPv4 address */
> +		else if (inet_pton(AF_INET6, name, buf) == 1)
> +			is_fqdn = 0; /* IPv6 addrss */
> +
> +		if (is_fqdn) {
>  			return strdup(name);
>  		}
> +		/* Sorry, cannot avoid dns after all */
>  	}
>  
>  	switch (sa->sa_family) {
