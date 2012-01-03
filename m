Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab2ACRIZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2012 12:08:25 -0500
Message-ID: <1325610502.16751.3.camel@lade.trondhjem.org>
Subject: Re: [PATCH] SUNRPC: Clean up the RPCSEC_GSS service ticket requests
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 03 Jan 2012 12:08:22 -0500
In-Reply-To: <20120103165544.GC6309@fieldses.org>
References: <1325608907-17801-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20120103165544.GC6309@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-01-03 at 11:55 -0500, Bruce Fields wrote: 
> On Tue, Jan 03, 2012 at 11:41:47AM -0500, Trond Myklebust wrote:
> > Instead of hacking specific service names into gss_encode_v1_msg, we should
> > just allow the caller to specify the service name explicitly.
> 
> Just curious: do you have some callers in mind he will need different
> service names?

Not for now, but I do expect that we might want to add lockd to the list
of RPCSEC_GSS-enabled services some day.

> (But I agree reagardless that this is the more logical layering; fwiw:
> 
> 	Acked-by: J. Bruce Fields <bfields@redhat.com>

Thanks!

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

