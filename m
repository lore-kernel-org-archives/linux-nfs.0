Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:59901 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751140Ab1IVPy0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 11:54:26 -0400
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore
 LOOKUP_FOLLOW
From: Ian Kent <raven@themaw.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        viro@zeniv.linux.org.uk, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
In-Reply-To: <6490.1316704925@redhat.com>
References: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
	 <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
	 <6490.1316704925@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Sep 2011 23:54:19 +0800
Message-ID: <1316706859.3346.37.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-22 at 16:22 +0100, David Howells wrote:
> 
> I would also say that we do not want lstat(), l*xattr() and co. to cause
> automounting - but maybe they should.  Perhaps if you don't want to cause
> automounting, you should explicitly pass AT_NO_AUTOMOUNT, and all path-taking
> VFS calls should have variants that accept this flag.

I still think we had it right the first time.

After all we have always said automounts are directories that have
symlink semantics, which to my way of thinking is what we now have (or
had). Not only that, it provides a natural way of ensuring a mount
occurs or does not occur by using the well known no follow calls.

The "natural" part of this is automounts can be followed conceptually in
the same way that symlinks can be followed.
I

