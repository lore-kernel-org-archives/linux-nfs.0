From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Confused about BUG_ON in rpcb_getport_async
Date: Wed, 13 Aug 2008 20:10:09 -0400
Message-ID: <1218672609.9042.86.camel@localhost>
References: <18592.62730.840231.108375@notabene.brown>
	 <1218573178.7253.31.camel@localhost>
	 <18595.29231.61262.220929@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:34890 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207AbYHNAKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 20:10:13 -0400
In-Reply-To: <18595.29231.61262.220929-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-08-14 at 09:45 +1000, Neil Brown wrote:
> Just to confirm,  you are saying that the current BUG_ON is indeed
> wrong, and the fact that it fires does not imply any real bug.
> It should be removed.  Possibly a BUG_ON could be put somewhere else
> to catch incorrect behaviour.
> 
> Is that correct?

Yes.

> I now have multiple people for whom this BUG_ON has fired.

Could you send us a trace? AFAIK it shouldn't really be happening...

Trond

