Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53402 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756146Ab1FGXH5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jun 2011 19:07:57 -0400
Date: Tue, 7 Jun 2011 19:07:54 -0400
To: Vladimir Elisseev <vovan@vovan.nl>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS3 + kerberos: performance issues
Message-ID: <20110607230754.GF13911@fieldses.org>
References: <1307086159.1052.19.camel@vovan.net.home>
 <1307104354.2477.17.camel@lade.trondhjem.org>
 <1307123836.1052.23.camel@vovan.net.home>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1307123836.1052.23.camel@vovan.net.home>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 03, 2011 at 07:57:16PM +0200, Vladimir Elisseev wrote:
> There's no mount command involved in timing. It's simply copy of the
> same directory (with many small files to NFS share with and without
> sec=krb5 mount option.

Weird.

I wonder if the krb5 principal is being mapped to a different user on
the server side, and that's making some difference.

Still, could you give us the full details?  (Exactly what commands are
you running, what results do you see?)

--b.
