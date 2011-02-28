Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:56711 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab1B1Vyk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Feb 2011 16:54:40 -0500
Date: Mon, 28 Feb 2011 16:54:39 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] zero out delegation in the inode after it has been
 returned
Message-ID: <20110228215439.GD1256@merit.edu>
References: <20110228213103.GA1256@merit.edu>
 <1298929144.8564.44.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298929144.8564.44.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:

  nfsi->delegation is released under the appropriate locks well before we
  get here. The above line is 100% racy and risks clobbering any new
  delegation that has been issued after the delegreturn completed...

I'd have been amazed if I'd gotten it right.  But there really is a problem
here, the client does try to use delegations that have been returned, and
this patch does solve that problem.  I'm happy to keep after this but would
appreciate any suggestions or nudges in the right direction.
