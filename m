Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43679 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753511Ab2CVV0S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 17:26:18 -0400
Date: Thu, 22 Mar 2012 17:26:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Change the default setting of the
 nfs4_disable_idmapping parameter
Message-ID: <20120322212616.GD23737@fieldses.org>
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120322204705.GA23737@fieldses.org>
 <1332449607.8976.9.camel@lade.trondhjem.org>
 <1332450074.8976.13.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332450074.8976.13.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 22, 2012 at 09:01:12PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-03-22 at 16:53 -0400, Trond Myklebust wrote:
> > Does the idmapper do the right thing for numeric ids these days? If the
> > older clients are running a newer idmapper that can deal with numeric
> > ids, then even the legacy clients should be able to work cleanly.
> 
> If this isn't the case, then the older clients are broken anyway. The
> server has always had the option of returning numeric ids if it has no
> mapping from a uid/gid into an owner/group string.

Hm, yes, but I was worried that the id<->name mapping might just be
different on the two sides--but if that's so, and they were using
auth_sys, then they likely already had problems.

So, maybe we could default this to on.

If that's the case then I'd rather not bother making this per export:
just an option to get the server back to its previous behavior would
seem enough.

--b.

> IOW: the only difference between older and newer clients should really
> be that the newer ones handle numeric strings more efficiently without
> requiring an upcall, and that the newer clients will also try to _send_
> numeric ids in SETATTR calls.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
