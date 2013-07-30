Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751501Ab3G3P71 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Jul 2013 11:59:27 -0400
Date: Tue, 30 Jul 2013 11:59:21 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] rpc.nfsd: Allow v4.2 server support with the -V
 option
Message-ID: <20130730155921.GE1443@fieldses.org>
References: <1375036598-31090-1-git-send-email-steved@redhat.com>
 <1375036598-31090-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1375036598-31090-2-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 28, 2013 at 02:36:38PM -0400, Steve Dickson wrote:
> Signed-off-by: Steve Dickson <steved@redhat.com>

I agree that we want to be able to turn on 4.2 support with -V, but this
does more than that:

> -	if (minorvers41)
> -		off += snprintf(ptr+off, sizeof(buf) - off, "%c4.1",
> -				minorvers41 > 0 ? '+' : '-');
> +	for (n = NFS4_MINMINOR; n <= NFS4_MAXMINOR; n++) {
> +		if (NFSCTL_VERISSET(minorvers, n)) 
> +			off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
> +		else			
> +			off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
> +	}
>  	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
>  		if (NFSCTL_VERISSET(ctlbits, n))
>  		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);

Previously minorvers41 could be set to:

	 1: turn on 4.1
	-1: turn off 4.1
	 0: keep kernel default (user didn't specify)

This patch removes the "0" case, which I liked.

--b.
