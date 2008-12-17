From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to
 enqueue 'XPT_DEAD' transports
Date: Wed, 17 Dec 2008 14:07:57 -0500
Message-ID: <1229540877.7257.97.camel@heimdal.trondhjem.org>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>
	 <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228090815.7112.15.camel@heimdal.trondhjem.org>
	 <49491C58.9@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, linux-nfs@vger.kernel.org,
	Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, linux-kernel@vger.kernel.org,
	gcosta@redhat.com, Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18674 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056AbYLQTIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 14:08:47 -0500
In-Reply-To: <49491C58.9@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-12-17 at 09:35 -0600, Tom Tucker wrote:
> Trond Myklebust wrote:
> > Aside from being racy (there is nothing preventing someone setting XPT_DEAD
> > after the test in svc_xprt_enqueue, and before XPT_BUSY is set), it is
> > wrong to assume that transports which have called svc_delete_xprt() might
> > not need to be re-enqueued.
> 
> This is only true because now you allow transports with XPT_DEAD set to 
> be enqueued -- yes?
> 
> > 
> > See the list of deferred requests, which is currently never going to
> > be cleared if the revisit call happens after svc_delete_xprt(). In this
> > case, the deferred request will currently keep a reference to the transport
> > forever.
> >
> 
> I agree this is a possibility and it needs to be fixed. I'm concerned 
> that the root cause is still there though. I thought the test case was 
> the client side timing out the connection. Why are there deferred 
> requests sitting on what is presumably an idle connection?

I haven't said that they are the cause of this test case. I've said that
deferred requests hold references to the socket that can obviously
deadlock. That needs to be fixed regardless of whether or not it is the
cause here.

There are plenty of situations in which the client may choose to close
the TCP socket even if there are outstanding requests. One of the most
common is when the user signals the process, so that an RPC call that
was partially transmitted (ran out of buffer space) gets cancelled
before it can finish transmitting. In that case the client has no choice
but to disconnect and immediately reconnect.

> > The fix should be to allow dead transports to be enqueued in order to clear
> > the deferred requests, then change the order of processing in svc_recv() so
> > that we pick up deferred requests before we do the XPT_CLOSE processing.
> > 
> 
> Wouldn't it be simpler to clean up any deferred requests in the close 
> path instead of changing the meaning of XPT_DEAD and dispatching 
> N-threads to do the same?

AFAICS, deferred requests are the property of the cache until they
expire or a downcall occurs. I'm not aware of any way to cancel only
those deferred requests that hold a reference to this particular
transport.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
