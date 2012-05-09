Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:48956 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759932Ab2EIUwu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 May 2012 16:52:50 -0400
Message-ID: <4FAAD91E.3090606@parallels.com>
Date: Thu, 10 May 2012 00:52:46 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: per-net rpc shutdown
References: <20120509142617.GA24233@fieldses.org>
In-Reply-To: <20120509142617.GA24233@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

09.05.2012 18:26, J. Bruce Fields написал:
> Reviewing your more recent patches I think we have a problem with some
> of the code that's already merged.  See the comment in svc_shutdown_net:
>
> 	void svc_shutdown_net(struct svc_serv *serv, struct net *net)
> 	{
> 		/*
> 		 * The set of xprts (contained in the sv_tempsocks and
> 		 * sv_permsocks lists) is now constant, since it is modified
> 		 * only by accepting new sockets (done by service threads in
> 		 * svc_recv) or aging old ones (done by sv_temptimer), or
> 		 * configuration changes (excluded by whatever locking the
> 		 * caller is using--nfsd_mutex in the case of nfsd).  So it's
> 		 * safe to traverse those lists and shut everything down:
> 		 */
> 		svc_close_net(serv, net);
> 	
> 		if (serv->sv_shutdown)
> 			serv->sv_shutdown(serv, net);
> 	}
>
> So we depend on the fact that neither the server threads nor
> sv_temptimer are running here to be able to safely traverse those lists
> of sockets.
>
> But it looks to me like that's no longer true--we're shutting down just
> one namespace here, and others may still be running.  If so and if they
> modify sv_tempsocks or sv_permsocks while we're running through them
> then we're going to get a crash.

Yes, you right. Thanks. I missed this.
You made some changes prior to my patches, which allowed to remove 
locking on these lists,if i'm not mistaken.
Anyway, read-write lock should be enough here, I suppose (I don't have 
sources right now to investigate) ?

