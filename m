From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount: ECONNREFUSED is a permanent error
Date: Fri, 09 Oct 2009 09:16:50 -0400
Message-ID: <4ACF37C2.6030208@RedHat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173703.12619.35788.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752798AbZJINRa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 09:17:30 -0400
In-Reply-To: <20091008173703.12619.35788.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/08/2009 01:37 PM, Chuck Lever wrote:
> I had assumed early on that mount.nfs should retry a refused connection.
> 
> Apparently this is not the case.  Legacy mount.nfs4 fails immediately
> if the NFS server refuses the connection.  Legacy mount.nfs and
> text-based mount.nfs both fail immediately if the rpcbind service is
> refusing connections.
> 
What about if the server is on the way up (i.e the network is up)
but has not started the NFS service? In that window, the server will 
return ECONNREFUSED since nobody is listening, but in a very short time
there will be a listener... The mount should not fail in that case...

steved.
 
