Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36365 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127Ab2AWWCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 17:02:05 -0500
Date: Mon, 23 Jan 2012 17:02:04 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Clean up the RPCSEC_GSS service ticket requests
Message-ID: <20120123220204.GC1452@fieldses.org>
References: <1325608907-17801-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120103165544.GC6309@fieldses.org>
 <20120123165124.GA32197@fieldses.org>
 <1327341448.2628.1.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327341448.2628.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 23, 2012 at 12:57:28PM -0500, Trond Myklebust wrote:
> Does the following patch help?

Yep!

	Tested-by: J. Bruce Fields <bfields@redhat.com>

--b.
