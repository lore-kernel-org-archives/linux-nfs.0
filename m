Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768657Ab2KOS7D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 13:59:03 -0500
Date: Thu, 15 Nov 2012 13:58:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>, simo@redhat.com
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before
 connecting local transports
Message-ID: <20121115185853.GA22448@fieldses.org>
References: <20121106133605.GD6718@fieldses.org>
 <20121107183355.GA7421@fieldses.org>
 <50A0B562.2090807@parallels.com>
 <20121114210112.GA539@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0A40@SACEXCMBX04-PRD.hq.netapp.com>
 <20121114214236.GB539@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0AE9@SACEXCMBX04-PRD.hq.netapp.com>
 <20121114215426.GC539@fieldses.org>
 <87obize6jp.fsf@xmission.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092E2984@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092E2984@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 15, 2012 at 01:34:16PM +0000, Myklebust, Trond wrote:
> On Wed, 2012-11-14 at 22:14 -0800, Eric W. Biederman wrote:
> > "J. Bruce Fields" <bfields@fieldses.org> writes:
> > 
> > > On Wed, Nov 14, 2012 at 09:51:33PM +0000, Myklebust, Trond wrote:
> > >> On Wed, 2012-11-14 at 16:42 -0500, J. Bruce Fields wrote:
> > >> > Simo's patches use them for upcalls to svcgssd.  Those will always be
> > >> > done from server threads.
> > >> 
> > >> Any reason why you can't set that up when you start nfsd?
> > >
> > > Oh, right, I was thinking of the upcalls themselves--right, the connect
> > > we should be able to do on server start, I agree.
> > >
> > >> 
> > >> > > If not, then let's just move
> > >> > > the AF_LOCAL connection back into the process context and out of rpciod.
> > >> > 
> > >> > Remind me how this helps?
> > >> 
> > >> rpciod shares the 'init' process net namespace and chroot properties.
> > >> If, however you call bind() from the (containerised) process that was
> > >> used to start nfsd, then you will be using filesystem root (and net
> > >> namespace) of that container.
> > >
> > > Got it.
> > 
> > If you can move the connect and bind into the server start that does
> > sound like a very good and maintainable solution.  I suspect it might
> > even be a smidge better for error handling.
> > 
> > Is there ever a reason to reconnect one of these sockets?
> 
> Not for the rpcbind case, however you can easily get into a situation
> where the user restarts the gss daemon. The good news is that the gss
> upcall code that uses AF_LOCAL hasn't been merged upstream yet, so that
> particular interface is not yet locked in stone.

I think we do want to be able to allow the daemon to be restarted.

I guess we can have it call into the rpc server code when it starts up
and the server could do the connect then?  We need some way for
userspace to tell the server that the new upcall is supported anyway.

--b.
