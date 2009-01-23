From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] nfs-utils: Don't do tcp wrapper check when there are no rules
Date: Fri, 23 Jan 2009 13:34:21 -0500
Message-ID: <D774CD22-5885-49AB-8483-EC68E95A3E50@oracle.com>
References: <497A056E.1030606@RedHat.com> <497A0862.40008@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:16821 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756830AbZAWSel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 13:34:41 -0500
In-Reply-To: <497A0862.40008-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm surprised this issue hasn't come up for other daemons (sshd  
perhaps?).  Is there code you could borrow for that?

Even better would be to fix tcp_wrappers to handle this optimization  
somehow itself.


On Jan 23, 2009, at Jan 23, 2009, 1:11 PM, Steve Dickson wrote:

> commit 58b7e3ef82c5d9e008befcce391027c4741d3a56
> Author: Steve Dickson <steved@redhat.com>
> Date:   Fri Jan 23 09:15:57 2009 -0500
>
>    If there are no rules in either /etc/hosts.deny or
>    /etc/hosts.allow there is no need to do the host validation.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
> index a450ad5..098406c 100644
> --- a/support/misc/tcpwrapper.c
> +++ b/support/misc/tcpwrapper.c
> @@ -34,6 +34,7 @@
> #ifdef HAVE_CONFIG_H
> #include <config.h>
> #endif
> +#include <stdio.h>
> #include <tcpwrapper.h>
> #include <unistd.h>
> #include <string.h>
> @@ -55,6 +56,8 @@
> #include <rpc/rpcent.h>
> #endif
>
> +static int check_files(void);
> +static int check_rules(void);
> static void logit(int severity, struct sockaddr_in *addr,
> 		  u_long procnum, u_long prognum, char *text);
> static void toggle_verboselog(int sig);
> @@ -175,6 +178,9 @@ struct sockaddr_in *addr;
>     char **sp;
>     char *tmpname;
>
> +	xlog(D_CALL, "good_client: %s: doing access check on %s",
> +		daemon, inet_ntoa(addr->sin_addr));
> +
> 	/* First check the address. */
> 	if (hosts_ctl(daemon, "", inet_ntoa(addr->sin_addr), "") == DENY)
> 		return DENY;
> @@ -262,8 +268,50 @@ void    check_startup(void)
>     (void) signal(SIGINT, toggle_verboselog);
> }
>
> +/*
> + * check_rules - check to see if any entries exist in
> + * either hosts file.
> + */
> +int check_rules()
> +{
> +	FILE *fp;
> +	char buf[BUFSIZ];
> +
> + 	if ((fp = fopen("/etc/hosts.allow", "r")) == NULL)
> +		return 0;
> +
> +	while (fgets(buf, BUFSIZ, fp) != NULL) {
> +		/* Check for commented lines */
> +		if (buf[0] == '#')
> +			continue;
> +		/* Check for blank lines */
> +		if (buf[strspn(buf, " \t\r\n")] == 0)
> +			continue;
> +		/* Not emtpy */
> +		fclose(fp);
> +		return 1;
> +	}
> +	fclose(fp);
> +
> +	if ((fp = fopen("/etc/hosts.deny", "r")) == NULL)
> +		return 0;
> +
> +	while (fgets(buf, BUFSIZ, fp) != NULL) {
> +		/* Check for commented lines */
> +		if (buf[0] == '#')
> +			continue;
> +		/* Check for blank lines */
> +		if (buf[strspn(buf, " \t\r\n")] == 0)
> +			continue;
> +		/* Not emtpy */
> +		fclose(fp);
> +		return 1;
> +	}
> +	fclose(fp);
> +	return 0;
> +}
> +
> /* check_files - check to see if either access files have changed */
> -
> static int check_files()
> {
> 	static time_t allow_mtime, deny_mtime;
> @@ -305,6 +353,13 @@ u_long  prog;
> 	if (acc && changed == 0)
> 		return (acc->access);
>
> +	/*
> +	 * See if there are any rules to be applied,
> +	 * if not, no need to check the address
> +	 */
> +	if (check_rules() == 0)
> +		goto done;
> +
> 	if (!(from_local(addr) || good_client(daemon, addr))) {
> 		log_bad_host(addr, proc, prog);
> 		if (acc)
> @@ -315,11 +370,12 @@ u_long  prog;
> 	}
> 	if (verboselog)
> 		log_client(addr, proc, prog);
> -
> +done:
> 	if (acc)
> 		acc->access = TRUE;
> 	else
> 		haccess_add(addr, prog, TRUE);
> +
>     return (TRUE);
> }

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
