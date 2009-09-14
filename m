From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] nfsd41: add RPC header size to fore channel
	negotiation
Date: Mon, 14 Sep 2009 15:03:15 -0400
Message-ID: <20090914190315.GD1658@fieldses.org>
References: <1252709575-3426-1-git-send-email-andros@netapp.com> <1252709575-3426-2-git-send-email-andros@netapp.com> <1252709575-3426-3-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55316 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756796AbZINTDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 15:03:12 -0400
In-Reply-To: <1252709575-3426-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2009 at 06:52:55PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Both the max request and the max response size include the RPC header with
> credential (request only)  and verifier as well as the payload.
> 
> The RPCSEC_GSS credential and verifier are the largest. Kerberos is the only
> supported GSS security mechansim, so the Kerberos GSS credential and verifier
> sizes are used.

Rather than trying to estimate this is might be simplest just to use
what the server's using to allocate memory: RPCSVC_MAXPAGES.  No, that
also takes into account space for the reply.  You could do

	PAGE_SIZE * (1 + (RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE)

Actually, by design the server's real limit is actually on the sum of
the request and the reply sizes.

What happens if we get a request such that both the request and reply
are under our advertised limits, but the sum is too much?  Can we just
declare that no client will be that weird and that we shouldn't have to
worry about it?

--b.
