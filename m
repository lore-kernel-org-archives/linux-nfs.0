From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mountd: Don't do tcp wrapper check when there are no rules
Date: Tue, 20 Jan 2009 11:03:23 -0500
Message-ID: <D93E60C8-C089-497F-9783-AA5DBE16A266@oracle.com>
References: <4975B412.9070509@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35530 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756029AbZATQDw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jan 2009 11:03:52 -0500
In-Reply-To: <4975B412.9070509-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 20, 2009, at Jan 20, 2009, 6:22 AM, Steve Dickson wrote:
> Its been point out that if there are are no rules in either
> /etc/hosts.deny or /etc/hosts.allow there is no need to do any
> validity checking on the incoming address.
>
> Unfortunately there is no interface that will easily
> let me know if there are any rules so I simply read
> in both files looking for non-commented lines.

I'm not familiar enough with the syntax of the hosts.* files, but it  
seems like you need something more sophisticated than this.  A quick  
skim of hosts.allow(5) and hosts_options(5) isn't illuminating.

Are blank lines allowed?  It is permitted to have white space before  
the "#"?

> steved.
>
>
> commit 5f09a2bacb4bf0a906e2d19931568b91fb6c5088
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Jan 20 06:16:56 2009 -0500
>
>    mountd: Don't do tcp wrapper check when there are no rules
>
>    If there are no rules in either /etc/hosts.deny or
>    /etc/hosts.allow there is no need to do the host validation.
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
> index 977dfca..af9813c 100644
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
> @@ -263,8 +266,40 @@ void    check_startup(void)
>     (void) signal(SIGINT, toggle_verboselog);
> }
>
> -/* check_files - check to see if either access files have changed */
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
> +		if (buf[0] == '#')
> +			continue;
> +		fclose(fp);
> +		return 1;
> +	}
> +	fclose(fp);
> +
> +	if ((fp = fopen("/etc/hosts.deny", "r")) == NULL)
> +		return 0;
>
> +	while (fgets(buf, BUFSIZ, fp) != NULL) {
> +		if (buf[0] == '#')
> +			continue;
> +		fclose(fp);
> +		return 1;
> +	}
> +	fclose(fp);
> +	return 0;
> +}
> +
> +/* check_files - check to see if either access files have changed */
> static int check_files()
> {
> 	static time_t allow_mtime, deny_mtime;
> @@ -306,6 +341,13 @@ u_long  prog;
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
> @@ -317,10 +359,12 @@ u_long  prog;
> 	if (verboselog)
> 		log_client(addr, proc, prog);
>
> +done:
> 	if (acc)
> 		acc->access = TRUE;
> 	else
> 		haccess_add(addr, proc, prog, TRUE);
> +
>     return (TRUE);
> }
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




