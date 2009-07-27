From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Slower performance with lookupcache (2.6.30.2)
Date: Mon, 27 Jul 2009 17:57:26 -0400
Message-ID: <1248731846.31801.66.camel@heimdal.trondhjem.org>
References: <20090724231300.GA572@hostway.ca>
	 <1248540703.6139.106.camel@heimdal.trondhjem.org>
	 <20090727170106.GA9330@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57662 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134AbZG0V5a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jul 2009 17:57:30 -0400
In-Reply-To: <20090727170106.GA9330@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-27 at 10:01 -0700, Simon Kirby wrote:
> You say that LOOKUP is returning the attributes as well -- is it not
> possible to operate the same way doing revalidation?

I'm not sure I understand you. Do you mean issue LOOKUP calls instead of
GETATTR calls when revalidating the file attribute information? Sure we
could, but LOOKUP is a more expensive operation than GETATTR on most
platforms: it requires the server to retrieve and process information
from both the parent directory and the file.

   Trond

