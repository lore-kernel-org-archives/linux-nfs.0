Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380AbaATWAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 17:00:45 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0KM0g8N029434
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 17:00:43 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-78.rdu2.redhat.com [10.10.58.78])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s0KM0fT2024260
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 17:00:41 -0500
Message-ID: <52DD9CFA.3010502@RedHat.com>
Date: Mon, 20 Jan 2014 17:02:34 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] exportfs: Don't buffer overflow on exports that are too
 big.
References: <1389206830-5368-1-git-send-email-steved@redhat.com>
In-Reply-To: <1389206830-5368-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/14 13:47, Steve Dickson wrote:
> Signe-doff-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/exportfs/exportfs.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 9ea86cb..8c86790 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -452,6 +452,8 @@ static int test_export(char *path, int with_fsid)
>  	bp += n;
>  	len -= n;
>  	qword_add(&bp, &len, path);
> +	if (len < 1)
> +		return 0;
>  	snprintf(bp, len, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
>  	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
>  	if (fd < 0)
> 
