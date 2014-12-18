Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail01-md.ns.itscom.net ([175.177.155.111]:57029 "EHLO
	mail01-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbaLRQ1Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 11:27:16 -0500
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs race
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@primarydata.com>
In-Reply-To: <20141218155838.GD18179@fieldses.org>
References: <20141217195911.GF9617@fieldses.org> <20141217200153.GG9617@fieldses.org> <12689.1418917838@jrobl> <20141218155838.GD18179@fieldses.org>
Date: Fri, 19 Dec 2014 01:27:14 +0900
Message-ID: <13170.1418920034@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


"J. Bruce Fields":
> Why do you think -EBUSY's the right error in the local filesystem case?

This busy_or_stale() is another bandaid, based upon your patch, EBUSY
--> ESTALE.
Because the msg string of ESTALE is "Stale NFS file handle" on many
systems, I don't think it a good idea to return it for local fs. If you
think EIO is better than EBUSY you can change it to eio_or_stale(). If
you think it is surely not happen on every local fs, then this inline
function is not necessary.


J. R. Okajima
