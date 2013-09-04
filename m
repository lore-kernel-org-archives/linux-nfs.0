Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33871 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490Ab3IDTix (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 15:38:53 -0400
Date: Wed, 4 Sep 2013 15:38:52 -0400
To: jupiter <jupiter.hce@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: NFS 4 error
Message-ID: <20130904193852.GD10232@fieldses.org>
References: <CAA=hcWR28P=bbJvZAmWRF9sr=0=B8SyBsq3U1x2-kTQ=Rr0U4A@mail.gmail.com>
 <20130904162045.GC7433@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130904162045.GC7433@us.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 04, 2013 at 11:20:45AM -0500, Malahal Naineni wrote:
> jupiter [jupiter.hce@gmail.com] wrote:
> > Hi,
> > 
> > I am running NFS 4 server on CentOS 6.4 for many months, it works
> > well. Recently I found that the dmesg display many following errors
> > but it still works. I searched google but could not find result of how
> > to fix it. What are those error message means? Are the errors serious
> > or not? How to fix it?
> > 
> > --------
> > rpc-srv/tcp: nfsd: got error -32 when sending 24 bytes - shutting down socket
> > rpc-srv/tcp: nfsd: got error -32 when sending 24 bytes - shutting down socket
> 
> When the nfsd (NFS server thread) was trying to send something, it got
> -32 (EPIPE) error.  I have seen this kind of errors when the socket is
> closed by clients.  Clients do close the socket (and recreate one) when
> they need to retry due to network failures.
> 
> They are NOT serious errors, and if they are still happening, then look
> at your network errors/retries etc.

We should really just demote this to a dprintk, in that case.

The network failures are potentially a serious problem if they mean the
client's forced to retry a nonidempotent operation.  But we probably
shouldn't be spamming the logs by default?

--b.
