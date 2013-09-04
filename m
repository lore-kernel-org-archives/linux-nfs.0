Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:43388 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755812Ab3IDTuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 15:50:24 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 4 Sep 2013 15:50:23 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4B5C1C90048
	for <linux-nfs@vger.kernel.org>; Wed,  4 Sep 2013 15:50:10 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r84Jo9Sg16318648
	for <linux-nfs@vger.kernel.org>; Wed, 4 Sep 2013 19:50:09 GMT
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r84Jo8VC008308
	for <linux-nfs@vger.kernel.org>; Wed, 4 Sep 2013 13:50:08 -0600
Date: Wed, 4 Sep 2013 14:50:07 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: jupiter <jupiter.hce@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS 4 error
Message-ID: <20130904195007.GC9877@us.ibm.com>
References: <CAA=hcWR28P=bbJvZAmWRF9sr=0=B8SyBsq3U1x2-kTQ=Rr0U4A@mail.gmail.com>
 <20130904162045.GC7433@us.ibm.com>
 <20130904193852.GD10232@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130904193852.GD10232@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> On Wed, Sep 04, 2013 at 11:20:45AM -0500, Malahal Naineni wrote:
> > jupiter [jupiter.hce@gmail.com] wrote:
> > > Hi,
> > > 
> > > I am running NFS 4 server on CentOS 6.4 for many months, it works
> > > well. Recently I found that the dmesg display many following errors
> > > but it still works. I searched google but could not find result of how
> > > to fix it. What are those error message means? Are the errors serious
> > > or not? How to fix it?
> > > 
> > > --------
> > > rpc-srv/tcp: nfsd: got error -32 when sending 24 bytes - shutting down socket
> > > rpc-srv/tcp: nfsd: got error -32 when sending 24 bytes - shutting down socket
> > 
> > When the nfsd (NFS server thread) was trying to send something, it got
> > -32 (EPIPE) error.  I have seen this kind of errors when the socket is
> > closed by clients.  Clients do close the socket (and recreate one) when
> > they need to retry due to network failures.
> > 
> > They are NOT serious errors, and if they are still happening, then look
> > at your network errors/retries etc.
> 
> We should really just demote this to a dprintk, in that case.
> 
> The network failures are potentially a serious problem if they mean the
> client's forced to retry a nonidempotent operation.  But we probably
> shouldn't be spamming the logs by default?

I haven't seen many of these messages. That is the only message logged when
the socket gets closed. It is a KERN_NOTICE level message. We can rate
limit it, but in my experience, I haven't seen a need for rate limiting
it.

Regards, Malahal.

