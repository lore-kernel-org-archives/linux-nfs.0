Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754885Ab2K1TxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 14:53:13 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qASJrDPq015413
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Nov 2012 14:53:13 -0500
Message-ID: <50B66BA9.7070107@RedHat.com>
Date: Wed, 28 Nov 2012 14:53:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsdcltrack: skip "." and ".." when trying to clean out
 legacy recdir
References: <1352753698-17693-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352753698-17693-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/11/12 15:54, Jeff Layton wrote:
> readdir picks up these two entries as "normal" dentries, but rmdir'ing
> them won't work (and we wouldn't want to remove them anyway).
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
> ---
>  utils/nfsdcltrack/nfsdcltrack.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
> index 9801b9c..4334340 100644
> --- a/utils/nfsdcltrack/nfsdcltrack.c
> +++ b/utils/nfsdcltrack/nfsdcltrack.c
> @@ -379,6 +379,17 @@ cltrack_legacy_gracedone(void)
>  	while ((entry = readdir(v4recovery))) {
>  		int len;
>  
> +		/* skip "." and ".." */
> +		if (entry->d_name[0] == '.') {
> +			switch (entry->d_name[1]) {
> +			case '\0':
> +				continue;
> +			case '.':
> +				if (entry->d_name[2] == '\0')
> +					continue;
> +			}
> +		}
> +
>  		/* borrow the clientid blob for this */
>  		len = snprintf((char *)blob, sizeof(blob), "%s/%s", dirname,
>  				entry->d_name);
> 
