Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38422 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759494Ab2EIO0S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 10:26:18 -0400
Date: Wed, 9 May 2012 10:26:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org
Subject: per-net rpc shutdown
Message-ID: <20120509142617.GA24233@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewing your more recent patches I think we have a problem with some
of the code that's already merged.  See the comment in svc_shutdown_net:

	void svc_shutdown_net(struct svc_serv *serv, struct net *net)
	{               
		/*      
		 * The set of xprts (contained in the sv_tempsocks and
		 * sv_permsocks lists) is now constant, since it is modified
		 * only by accepting new sockets (done by service threads in
		 * svc_recv) or aging old ones (done by sv_temptimer), or
		 * configuration changes (excluded by whatever locking the
		 * caller is using--nfsd_mutex in the case of nfsd).  So it's
		 * safe to traverse those lists and shut everything down:
		 */       
		svc_close_net(serv, net);
	
		if (serv->sv_shutdown)
			serv->sv_shutdown(serv, net);
	}

So we depend on the fact that neither the server threads nor
sv_temptimer are running here to be able to safely traverse those lists
of sockets.

But it looks to me like that's no longer true--we're shutting down just
one namespace here, and others may still be running.  If so and if they
modify sv_tempsocks or sv_permsocks while we're running through them
then we're going to get a crash.

--b.
