Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38802 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765Ab0GVM1S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 08:27:18 -0400
Date: Thu, 22 Jul 2010 08:26:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Staubach_Peter@emc.com
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #4)
Message-ID: <20100722122630.GA13640@fieldses.org>
References: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
 <20100721201437.GD28123@fieldses.org>
 <BF3BB6D12298F54B89C8DCC1E4073D8001E488B3@CORPUSMX50A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D8001E488B3@CORPUSMX50A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 22, 2010 at 07:59:39AM -0400, Staubach_Peter@emc.com wrote:
> +static int nfsd_init_socks(int port)
> +{
> +	int error;
> +	if (!list_empty(&nfsd_serv->sv_permsocks))
> +		return 0;
> +
> +	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
> +					SVC_SOCK_DEFAULTS);
> +	if (error < 0)
> +		return error;
> +
> +	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
> +					SVC_SOCK_DEFAULTS);
> +	if (error < 0)
> +		return error;
> 
> Doesn't this leave something dangling if svc_create_xprt for "udp"
> succeeds,
> but svc_create_xprt for "tcp" fails?

Yeah, but those sockets are all cleaned up when nfsd_serv is destroyed,
so I think we can live with this.

--b.
