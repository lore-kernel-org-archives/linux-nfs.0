Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55718 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752376Ab0G0Isw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Jul 2010 04:48:52 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1280202225.2944.20.camel@localhost>
References: <1280202225.2944.20.camel@localhost> <1280157768.3569.14.camel@localhost> <1279944664.2944.8.camel@localhost> <20100722175847.5552.11520.stgit@warthog.procyon.org.uk> <17723.1279897759@redhat.com> <9168.1280153997@redhat.com> <30118.1280159695@redhat.com>
To: Ian Kent <raven@themaw.net>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] Add a dentry op to handle automounting rather than abusing follow_link() [ver #2]
Date: Tue, 27 Jul 2010 09:48:41 +0100
Message-ID: <12883.1280220521@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Ian Kent <raven@themaw.net> wrote:

> Is this something others need?

Not as far as I know...  I think autofs is the only one doing out-of-kernel
automounting.

That doesn't mean it shouldn't be provided, though...

> Again, the exists vs not yet exists case for paths within indirect
> autofs mounts. At the moment I can just set the flag on all dentrys in
> the autofs fs and return EXDEV for non-empty directories in order to
> return the dentry as a path component. OTOH if the dentry is a mount
> embeded in the path and the mount fails we get a error return.

Seems redundant, but I'd say go with it for now.  Maybe we can offload
S_AUTOMOUNT to the dentry.

> I could clear the flag on non-root parent dentrys during mkdir if this
> is needed by others.

I'm not sure that would actually matter, since it would come to
follow_automount() at the same place.

Note that someone who tries to stat() with AT_NO_AUTOMOUNT will cause the call
to d_automount() to be suppressed and will see the negative or non-mounted
directory.  That might be okay for you.

David
