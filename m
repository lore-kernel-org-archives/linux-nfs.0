Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACCC9C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 18:50:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70DB2206BA
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 18:50:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726787AbfCDSuz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 13:50:55 -0500
Received: from mx1.redhat.com ([209.132.183.28]:39628 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726217AbfCDSuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Mar 2019 13:50:55 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 32DA33082E23
        for <linux-nfs@vger.kernel.org>; Mon,  4 Mar 2019 18:50:55 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-96.phx2.redhat.com [10.3.116.96])
        by smtp.corp.redhat.com (Postfix) with ESMTP id EB4561001DD0
        for <linux-nfs@vger.kernel.org>; Mon,  4 Mar 2019 18:50:54 +0000 (UTC)
Subject: Re: [PATCH] Add nfs.conf equivalent for the statd --no-notify cmdline
 option
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20190304165723.24097-1-steved@redhat.com>
From:   Steve Dickson <SteveD@RedHat.com>
Message-ID: <9690009b-1026-06c8-623a-bb58e43f53ad@RedHat.com>
Date:   Mon, 4 Mar 2019 13:50:54 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190304165723.24097-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Mon, 04 Mar 2019 18:50:55 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On 3/4/19 11:57 AM, Steve Dickson wrote:
> From: Justin Mitchell <jumitche@redhat.com>
> 
> Also cleaned up how nfs.conf is read.
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  nfs.conf            |  1 +
>  utils/statd/statd.c | 55 ++++++++++++++++++++++++++++-----------------
>  2 files changed, 36 insertions(+), 20 deletions(-)
> 
> diff --git a/nfs.conf b/nfs.conf
> index f1ebfdb..d332375 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -62,6 +62,7 @@
>  # name=
>  # state-directory-path=/var/lib/nfs/statd
>  # ha-callout=
> +# no-notify=0
>  #
>  [sm-notify]
>  # debug=0
> diff --git a/utils/statd/statd.c b/utils/statd/statd.c
> index 2cc6cf3..1467380 100644
> --- a/utils/statd/statd.c
> +++ b/utils/statd/statd.c
> @@ -238,6 +238,39 @@ static void set_nlm_port(char *type, int port)
>  		fprintf(stderr, "%s: failed to open %s: %s\n", 
>  			name_p, pathbuf, strerror(errno));
>  }
> +int port = 0, out_port = 0;
> +int nlm_udp = 0, nlm_tcp = 0;
> +
> +inline static void 
> +read_nfsconf(char **argv)
> +{
> +	char *s;
> +
> +	conf_init_file(NFS_CONFFILE);
> +	xlog_from_conffile("statd");
> +
> +	out_port = conf_get_num("statd", "outgoing-port", out_port);
> +	port = conf_get_num("statd", "port", port);
> +
> +	MY_NAME = conf_get_str("statd", "name");
> +	if (MY_NAME)
> +		run_mode |= STATIC_HOSTNAME;
> +
> +	s = conf_get_str("statd", "state-directory-path");
> +	if (s && !nsm_setup_pathnames(argv[0], s))
> +		exit(1);
> +
> +	s = conf_get_str("statd", "ha-callout");
> +	if (s)
> +		ha_callout_prog = s;
> +
> +	nlm_tcp = conf_get_num("lockd", "port", nlm_tcp);
> +	/* udp defaults to the same as tcp ! */
> +	nlm_udp = conf_get_num("lockd", "udp-port", nlm_tcp);
> +
> +	if (conf_get_bool("statd", "no-notify", false))
> +		run_mode |= MODE_NO_NOTIFY;
> +}
>  
>  /*
>   * Entry routine/main loop.
> @@ -245,11 +278,8 @@ static void set_nlm_port(char *type, int port)
>  int main (int argc, char **argv)
>  {
>  	extern char *optarg;
> -	char *s;
>  	int pid;
>  	int arg;
> -	int port = 0, out_port = 0;
> -	int nlm_udp = 0, nlm_tcp = 0;
>  	struct rlimit rlim;
>  	int notify_sockfd;
>  	char *env;
> @@ -275,23 +305,8 @@ int main (int argc, char **argv)
>  	/* Set hostname */
>  	MY_NAME = NULL;
>  
> -	conf_init_file(NFS_CONFFILE);
> -	xlog_from_conffile("statd");
> -	out_port = conf_get_num("statd", "outgoing-port", out_port);
> -	port = conf_get_num("statd", "port", port);
> -	MY_NAME = conf_get_str("statd", "name");
> -	if (MY_NAME)
> -		run_mode |= STATIC_HOSTNAME;
> -	s = conf_get_str("statd", "state-directory-path");
> -	if (s && !nsm_setup_pathnames(argv[0], s))
> -		exit(1);
> -	s = conf_get_str("statd", "ha-callout");
> -	if (s)
> -		ha_callout_prog = s;
> -
> -	nlm_tcp = conf_get_num("lockd", "port", nlm_tcp);
> -	/* udp defaults to the same as tcp ! */
> -	nlm_udp = conf_get_num("lockd", "udp-port", nlm_tcp);
> +	/* Read nfs.conf */
> +	read_nfsconf(argv);
>  
>  	/* Process command line switches */
>  	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:LT:U:", longopts, NULL)) != EOF) {
> 
