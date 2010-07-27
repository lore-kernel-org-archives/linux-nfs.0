Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:47341 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751975Ab0G0Mvj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jul 2010 08:51:39 -0400
Subject: Re: [PATCH 1/6] Add a dentry op to handle automounting rather than
 abusing follow_link() [ver #2]
From: Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <12883.1280220521@redhat.com>
References: <1280202225.2944.20.camel@localhost>
	 <1280157768.3569.14.camel@localhost> <1279944664.2944.8.camel@localhost>
	 <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
	 <17723.1279897759@redhat.com> <9168.1280153997@redhat.com>
	 <30118.1280159695@redhat.com>  <12883.1280220521@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Jul 2010 20:51:18 +0800
Message-ID: <1280235078.2946.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-07-27 at 09:48 +0100, David Howells wrote:
> Ian Kent <raven@themaw.net> wrote:
> 
> > Is this something others need?
> 
> Not as far as I know...  I think autofs is the only one doing out-of-kernel
> automounting.
> 
> That doesn't mean it shouldn't be provided, though...
> 
> > Again, the exists vs not yet exists case for paths within indirect
> > autofs mounts. At the moment I can just set the flag on all dentrys in
> > the autofs fs and return EXDEV for non-empty directories in order to
> > return the dentry as a path component. OTOH if the dentry is a mount
> > embeded in the path and the mount fails we get a error return.
> 
> Seems redundant, but I'd say go with it for now.  Maybe we can offload
> S_AUTOMOUNT to the dentry.

Yes, it is redundant but it is simple and works fine as long as I don't
apply the patch to return -EREMOTE for non-terminal dentrys. I'd need to
clear the flag, as below, on non-terminal dentrys if the -EREMOTE patch
is needed.

> 
> > I could clear the flag on non-root parent dentrys during mkdir if this
> > is needed by others.
> 
> I'm not sure that would actually matter, since it would come to
> follow_automount() at the same place.
> 
> Note that someone who tries to stat() with AT_NO_AUTOMOUNT will cause the call
> to d_automount() to be suppressed and will see the negative or non-mounted
> directory.  That might be okay for you.

With one small correction to the autofs patch I've been able to
successfully run the autofs Connectathon parser test without any user
space changes for both the nobrowse (the usual case) and the browse
(pre-created mount point directories) cases. The test consists of 230
mounts, with success and fail cases, for both direct and indirect
mounts. These mounts include various offset mount constructs as well. To
consider the test a success I require the mounts to also expire
correctly.

There are more tests to run, such as the program mount test, and the
often problematic submount test. Also, I have a submount based stress
test.

But, all in all, this is shaping up to be just what I need. Having one
single place to call back to the daemon, where I don't need to play
around with the inode mutex, makes me think this implementation will
finally resolve my deadlock issue with indirect mounts.

Ian


