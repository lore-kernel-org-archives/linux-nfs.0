Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755559Ab3BZN2A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2013 08:28:00 -0500
Subject: Re: [PATCH 6/6] SUNRPC: Use gssproxy upcall for server RPCGSS
 authentication.
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        chuck.lever@oracle.com
In-Reply-To: <20130221210139.GF3531@pad.fieldses.org>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
	 <1361464705-12340-7-git-send-email-bfields@redhat.com>
	 <20130221210139.GF3531@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Feb 2013 08:27:51 -0500
Message-ID: <1361885271.2962.1.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-02-21 at 16:01 -0500, J. Bruce Fields wrote:
> On Thu, Feb 21, 2013 at 11:38:25AM -0500, J. Bruce Fields wrote:
> > +NFS Server New RPC Upcall Mechanism
> > +-----------------------------------
> > +
> > +The newer upcall mechanism uses RPC over a unix socket to a daemon
> > +called gss-proxy, implemented by a userspace program called Gssproxy.
> > +
> > +The gss_proxy RPC protocol is currently documented here:
> > +
> > +	https://fedorahosted.org/gss-proxy/wiki/ProtocolDocumentation
> 
> By the way, Simo, that still says "The protocol is not stable yet and it
> is being revised while we progress prototyping client and server code."
> 
> I'm assuming that web page is just out of date--once this is in the
> kernel we're *not* making backwards-incompatible changes to the
> protocol.

The part that is used by the kernel is already marked as unchangeable in
my mind, I will try to take some time in the next few weeks to update
the page.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

