From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/38] svc: Make svc_sock the tcp/udp transport
Date: Thu, 13 Dec 2007 14:01:13 -0500
Message-ID: <20071213190113.GC29496@fieldses.org>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int> <20071211233156.15718.7813.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43915 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759369AbXLMTBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2007 14:01:17 -0500
In-Reply-To: <20071211233156.15718.7813.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2007 at 05:31:56PM -0600, Tom Tucker wrote:
> @@ -1965,3 +1995,4 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
>  	spin_unlock(&svsk->sk_lock);
>  	return dr;
>  }
> +

??

--b.
