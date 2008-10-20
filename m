From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] sunrpc: add sv_maxconn field to svc_serv
Date: Mon, 20 Oct 2008 11:41:58 +1100
Message-ID: <18683.54230.620237.699323@notabene.brown>
References: <1224334967-24754-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:46622 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024AbYJTAly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Oct 2008 20:41:54 -0400
In-Reply-To: message from Jeff Layton on Saturday October 18
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday October 18, jlayton@redhat.com wrote:
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 3afe7fb..048da8a 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -61,6 +61,7 @@ struct svc_serv {
>  	unsigned int		sv_max_payload;	/* datagram payload size */
>  	unsigned int		sv_max_mesg;	/* max_payload + 1 page for overheads */
>  	unsigned int		sv_xdrsize;	/* XDR buffer size */
> +	unsigned int		sv_maxconn;	/* max connections allowed
  +                                              * or '0' causing max
  +						 * to be dynamic based on
  +						 * number of threads. */

Otherwise I am completely happy with these patches.

Thanks,
NeilBrown
