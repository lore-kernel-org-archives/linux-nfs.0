From: Neil Brown <neilb@suse.de>
Subject: Confused about BUG_ON in rpcb_getport_async
Date: Tue, 12 Aug 2008 12:27:22 +1000
Message-ID: <18592.62730.840231.108375@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34109 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbYHLC13 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 22:27:29 -0400
Received: from Relay2.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id A4CDC45D89
	for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2008 04:27:28 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi 
 I have a report of a the BUG_ON in rpcb_getport_clnt being
 triggered.  This is:
	/* Autobind on cloned rpc clients is discouraged */
	BUG_ON(clnt->cl_parent != clnt);

 It looks to me that while they might be discouraged, they are not
 prevented and so having the BUG_ON is wrong.

 When rpc_clone_client creates a clone, it sets cl_autobind to 0,
 and gives the new client a reference to the same cl_xprt as the
 original client.

 The only effect of cl_autobind is to prevent rpc_force_rebind from
 clearing the BOUND flag on ->cl_xprt.
 So while a call to rpc_force_rebind on the clone will not clear that
 flag, a call on the original client will clear that flag.

 So a cloned client can still end up with a ->cl_xprt with the BOUND
 flag clear.

 So call_bind (which is present in the call trace under the oops) can
 find that !xprt_bound, even when the client is a cloned client.

 When this happens, ->rpcbind, which is rpcb_getport_clnt, goes BOOM.

 What should happen when a clone client finds that its transport is no
 longer bound?  Should rpc_getport_async just do
    clnt = task->tk_client->cl_parent;
 ??

Perplexed,
NeilBrown
