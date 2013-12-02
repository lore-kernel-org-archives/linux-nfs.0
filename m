Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33930 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3LBIMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 03:12:34 -0500
Date: Mon, 2 Dec 2013 00:12:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biederman <ebiederm@xmission.com>
Subject: Re: [PATCH 00/11] [RFC] repair net namespace damage to rpc_pipefs
Message-ID: <20131202081233.GA6953@infradead.org>
References: <20131201131441.790963326@bombadil.infradead.org>
 <20131201181329.GC10323@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131201181329.GC10323@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 01, 2013 at 06:13:29PM +0000, Al Viro wrote:
> Making the series no-go in that form, obviously.

Looking at the mess it made I'd almost be tempted to say a little leak
for a less used features is better than lots of pain for everyone..

Looking at the mess it made I'm really upset.

> > Given that the namespace kraken has infected various internal filesystem
> > and will get more soon I suspect this problem is or will become generic
> > and will need a proper solution anyway.  Al, any good ideas how to deal
> > with this?  Most straight forward way would be to add a counter of
> > user vfsmount to the superblock and methods when it goes to 1 and 0,
> > but that seems a bit ugly.
> 
> Folks, please, _please_, let's formulate the lifecycle rules first; we
> already had way too much trouble from putting mechanism first only to
> run into questions like the above ("what happens if somebody tries to
> allocate a PID in pid_ns that is already scheduled for shutdown?").
> Remember the (recurring) fun with kobject-related lifetime issues?
> Or rpc_pipefs notifier ugliness, for that matter...

I'll have to let the net namespace folks chime in for that, as far as
I'm concerned it's a featured better config'ed off.  If they can't come
up with anything better the procfs hack above would be it.
