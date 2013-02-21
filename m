Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753719Ab3BUVBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 16:01:42 -0500
Date: Thu, 21 Feb 2013 16:01:39 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, chuck.lever@oracle.com, simo@redhat.com
Subject: Re: [PATCH 6/6] SUNRPC: Use gssproxy upcall for server RPCGSS
 authentication.
Message-ID: <20130221210139.GF3531@pad.fieldses.org>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
 <1361464705-12340-7-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1361464705-12340-7-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2013 at 11:38:25AM -0500, J. Bruce Fields wrote:
> +NFS Server New RPC Upcall Mechanism
> +-----------------------------------
> +
> +The newer upcall mechanism uses RPC over a unix socket to a daemon
> +called gss-proxy, implemented by a userspace program called Gssproxy.
> +
> +The gss_proxy RPC protocol is currently documented here:
> +
> +	https://fedorahosted.org/gss-proxy/wiki/ProtocolDocumentation

By the way, Simo, that still says "The protocol is not stable yet and it
is being revised while we progress prototyping client and server code."

I'm assuming that web page is just out of date--once this is in the
kernel we're *not* making backwards-incompatible changes to the
protocol.

--b.
