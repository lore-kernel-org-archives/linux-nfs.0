From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 14/24] Removed warnings from idmapd.c
Date: Wed, 21 Jul 2010 13:24:45 -0400
Message-ID: <20100721172445.GD26418@fieldses.org>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
 <1279669057-17509-15-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56768 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235Ab0GURZ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 13:25:29 -0400
In-Reply-To: <1279669057-17509-15-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 20, 2010 at 07:37:27PM -0400, Steve Dickson wrote:
> idmapd.c:120: warning: missing initializer
> idmapd.c:120: warning: (near initialization for 'nfsd_ic[0].ic_event')
> idmapd.c:121: warning: missing initializer
> idmapd.c:121: warning: (near initialization for 'nfsd_ic[1].ic_event')
> idmapd.c: In function 'flush_nfsd_cache':
> idmapd.c:173: warning: comparison between signed and unsigned integer expressions
> idmapd.c: In function 'dirscancb':
> idmapd.c:384: warning: unused parameter 'fd'
> idmapd.c:384: warning: unused parameter 'which'
...
> @@ -389,6 +405,8 @@ dirscancb(int fd, short which, void *data)
>  	char path[PATH_MAX];
>  	struct idmap_clientq *icq = data;
>  
> +	xlog(D_GENERAL, "dirscancb: fd %d which %d data %p", fd, which, data);
> +

Some comment as before--let's not put information in the logs that's not
useful, just to silence a gcc warning.

--b.
