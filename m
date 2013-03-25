Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756358Ab3CYOQa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 10:16:30 -0400
Message-ID: <51505C36.5000508@RedHat.com>
Date: Mon, 25 Mar 2013 10:16:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd - expired credentials problem
References: <20130309112531.GA13250@ics.muni.cz>
In-Reply-To: <20130309112531.GA13250@ics.muni.cz>
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/03/13 06:25, Lukas Hejtmanek wrote:
> Hi,
> 
> I noticed that there is a problem with expired credentials if NFS client's
> time is even few seconds behind KDC's or NFS server's time. Client's kernel
> requests new GSS context but rpc.gssd is happy with existing krb cache as it
> valid according to local time.
> 
> Is there any reason for gssd to check validity of existing cache when kernel
> requests a new context?
> 
> However, it seems that this trivial patch solves this issue.
> 
> 300 is because I believe that clock skew must be within 300sec for kerberos.
> 
> Signed-off-by: Lukas Hejtmanek <xhejtman@gmail.com>
Committed...

steved.

> 
> diff -rNu nfs-utils-1.2.7.orig/utils/gssd/krb5_util.c nfs-utils-1.2.7/utils/gssd/krb5_util.c
> --- nfs-utils-1.2.7.orig/utils/gssd/krb5_util.c 2012-11-12 00:01:23.000000000 +0100
> +++ nfs-utils-1.2.7/utils/gssd/krb5_util.c      2013-02-15 16:35:35.652482164 +0100
> @@ -343,7 +343,7 @@
>         char kt_name[BUFSIZ];
>         char cc_name[BUFSIZ];
>         int code;
> -       time_t now = time(0);
> +       time_t now = time(0)+300; // workaround for clock skew among NFS server, NFS client and KDC
>         char *cache_type;
>         char *pname = NULL;
>         char *k5err = NULL;
> 
> 
