Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:48823 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754396Ab0GZPXA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 11:23:00 -0400
Subject: Re: [PATCH 1/6] Add a dentry op to handle automounting rather than
 abusing follow_link() [ver #2]
From: Ian Kent <raven@themaw.net>
To: David Howells <dhowells@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <9168.1280153997@redhat.com>
References: <1279944664.2944.8.camel@localhost>
	 <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
	 <17723.1279897759@redhat.com>  <9168.1280153997@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 26 Jul 2010 23:22:48 +0800
Message-ID: <1280157768.3569.14.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-07-26 at 15:19 +0100, David Howells wrote:
> Ian Kent <raven@themaw.net> wrote:
> 
> > >  (4) Stops pathwalk at the automount point and returns that point in the fs
> > >      tree if it decides not to automount rather than reporting ELOOP (see its
> > >      use of EXDEV for this).
> 
> Does it make autofs easier if d_op->d_automount() is allowed to return -EXDEV
> to request this?  Then you can return it in Oz mode to allow the daemon to
> see/use the underlying mountpoint without recursing back into d_automount().

Yes, it's really useful.

> 
> Ideally, the daemon would use AT_NO_AUTOMOUNT, but there's no way to pass that
> to sys_mount() or sys_umount().

The use of EXDEV, and if we had a way of saying we want a negative
dentry to trigger a mount, allows this mechanism to work for autofs
without any user space changes for direct and indirect mounts, at least
to match the current function.

Having said that though I've only just begun to test the various cases.

I know this was originally meant to deal with just the follow_link abuse
but the approach as it is appears to be able to resolve a long standing
deadlock bug autofs has with indirect mounts and affords a huge amount
of simplification to the autofs module code. I really hope we can work
out a suitable way to change the implementation to allow for negative
dentrys to trigger mounts. Of course it's quite possible I'll hit a snag
during testing but I hope not as I've spent a lot of time on alternate
approaches in the last few years.

Ian

