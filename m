Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13002 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757164Ab3ETVLE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 May 2013 17:11:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 6/6] NFSv4.1: Enable state protection
Date: Mon, 20 May 2013 21:10:46 +0000
Message-ID: <1369084243.52168.1.camel@leira.trondhjem.org>
References: <1369070227-40671-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1369070227-40671-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1369070227-40671-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1369070227-40671-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1369070227-40671-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1369070227-40671-6-git-send-email-Trond.Myklebust@netapp.com>
	 <20130520204009.GH14677@fieldses.org>
In-Reply-To: <20130520204009.GH14677@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-20 at 16:40 -0400, J. Bruce Fields wrote:
> On Mon, May 20, 2013 at 01:17:07PM -0400, Trond Myklebust wrote:
> > Use the EXCHGID4_FLAG_BIND_PRINC_STATEID exchange_id flag to enable
> > stateid protection. This means that if we create a stateid using a
> > particular principal, then we must use the same principal if we
> > want to change that state.
> 
> Note that knfsd ignores this--its EXCHANGE_ID will always return with
> the flag unset regardless of what the client requests.  My understanding
> is that that's legal ("Whether a bit is set or cleared on the arguments'
> flags does not force the server to set or clear the same bit on the
> results' side.")
> 
> (Definitely not opposed to implementing it, just haven't gotten around
> to it.)

Right, but the point here is that the server is allowed to set
EXCHGID4_FLAG_BIND_PRINC_STATEID without the client requesting it, so
the client is supposed to always be ready for that situation.

This patch series is therefore more about ensuring that the Linux client
is spec compliant.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
