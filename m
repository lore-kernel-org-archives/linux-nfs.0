From: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Subject: Re: NFS, race in writeback?
Date: Mon, 24 May 2010 13:56:44 +0900
Message-ID: <28595.1274677004@jrobl>
References: <11621.1274548448@jrobl> <1274640976.4860.97.camel@heimdal.trondhjem.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi12.ns.itscom.net ([219.110.2.182]:51519 "EHLO
	mtoichi12.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab0EXE5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 00:57:13 -0400
In-Reply-To: <1274640976.4860.97.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust:
> Urgh. Yes, this looks like it is a consequence of commit
> ba8b06e67ed7a560b0e7c80091bcadda4f4727a5. We need to revert the part
> that calls sync_inode().
>
> Does the following fix it for you?

Applying the patch against 2.6.34, it passed my local stress test for
two hours. The problem was fixed. Thank you.


J. R. Okajima
