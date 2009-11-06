From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] NLM server can not process retransmited request correctly
Date: Fri, 6 Nov 2009 18:07:22 -0500
Message-ID: <20091106230722.GN18459@fieldses.org>
References: <4AEEA622.6000705@cn.fujitsu.com> <20091102200956.GC19271@fieldses.org> <4AEFF9D2.8030506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	NFSv3 list <linux-nfs@vger.kernel.org>, mingo@elte.hu
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34387 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759989AbZKFXHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Nov 2009 18:07:19 -0500
In-Reply-To: <4AEFF9D2.8030506@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 03, 2009 at 05:37:22PM +0800, Mi Jinlong wrote:
> Hi Bruce
> 
>  Thanks for your answer.
> 
> J. Bruce Fields:
> > On Mon, Nov 02, 2009 at 05:28:02PM +0800, Mi Jinlong wrote:
> >> Hi Trond et al:
> >>
> 
> ..snip..
> 
> >>    Server reply ENOLCK for WL1 to client because nfslock service stoped,
> > 
> > I don't completely understand that part: is it because the monitor call
> > to statd fails?
> 
> yes. 
> 
> > 
> >>    but it can not distinguish retransmited request with normal request, 
> >>    so it reply OK for WL1_re to client after nfslock service start. But 
> >>    fcntl client called will return when it receive WL1.reply, WL1_re.reply
> >>    will be droped at Client. So that, the lock between client and server
> >>    is different. When client send a some lock request to server again,
> >>    it will get a EBLOCKD error from Server.
> > 
> > But, OK, I get the idea, and generic DRC code shared by nfsd and nlm
> > makes sense to me; thanks for looking into this.
> 
> In my patch, the generic DRC code as a part of sunrpc, is it ok? or we
> should put it at fs/nfs_common?

Sunrpc makes sense to me; this should be purely rpc-level code without
any special knowledge of nfs.

--b.
