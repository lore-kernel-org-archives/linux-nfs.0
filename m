From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 05/12] lockd: encapsulate nlm_hosts table variables in
 one structure
Date: Wed, 05 Nov 2008 18:11:50 -0500
Message-ID: <1225926710.16857.94.camel@heimdal.trondhjem.org>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
	 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
	 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
	 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
	 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
	 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
	 <5C259444-2EA3-489E-9FC9-5983DDE74950@oracle.com>
	 <20081105224109.GN1455@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35408 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbYKEXL7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 18:11:59 -0500
In-Reply-To: <20081105224109.GN1455@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-11-05 at 17:41 -0500, J. Bruce Fields wrote:
> I always figured we should get rid of the garbage collection entirely.

That would lead to NSM_MON/UNMON storms on an insane scale if you have
an application like a mail server that is constantly locking and
unlocking files.

Trond

