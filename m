Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47776 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751228AbdJZWk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Oct 2017 18:40:26 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1509038513.29077.31.camel@redhat.com>
References: <1509038513.29077.31.camel@redhat.com> <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk> <150730500019.6182.15975727444128962384.stgit@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 07/14] VFS: Add a sample program for fsopen/fsmount [ver #6]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 26 Oct 2017 23:40:24 +0100
Message-ID: <7973.1509057624@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> So to make sure I understand....
> 
> Suppose I want to do a bind mount with the new API. Would I do something
> like this?
> 
>     mfd = fsopen("???");
>     write(mfd, "s /path/to/old/mount");

You would have to use something other than "s" as that indicates the medium
source, but there are plenty of other options.  Alternatively, something like:

	mfd = mntopen("/path/to/old/mount", ...);

You would need some way to retrieve the fs type, though.  Maybe the first
read() you do will return it:

	char fstype[256];
	read(mfd, fstype, 256);

ends up with:

	"fs <type>"

in the buffer, though I think I'd prefer it to be manually elicited.

>     write(mfd, "o bind");

This is unnecessary as you can just do:

>     fsmount(mfd, ...);

at this point to achieve the effect.

> That seems a bit klunkier than before as I now need to pay attention to
> the fstype. I guess I'd have to scrape /proc/mounts for that info?

I haven't worked out this interface yet.  I'm not sure it's actually necessary
at this point, though it'd be nice to have.

David
