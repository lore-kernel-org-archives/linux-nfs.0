Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736Ab1IVPX2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 11:23:28 -0400
Date: Thu, 22 Sep 2011 11:26:36 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, miklos@szeredi.hu, raven@themaw.net,
        viro@zeniv.linux.org.uk, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Subject: Re: [PATCH] NFS4: Revert commit to make the automount code ignore
 LOOKUP_FOLLOW
Message-ID: <20110922112636.05f9fc9a@barsoom.rdu.redhat.com>
In-Reply-To: <CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
References: <20110922124608.7739.27750.stgit@warthog.procyon.org.uk>
	<CA+55aFzoH2VxTvf3Q1Lp_GAqDNAbsSOa=ATFXYSmmM=K8Fhuew@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 22 Sep 2011 07:33:43 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Sep 22, 2011 at 5:46 AM, David Howells <dhowells@redhat.com> wrote:
> >
> >  (4) Add a new flag, say LOOKUP_GETTING_ATTRS, to indicate that we're doing a
> >     stat() or a getxattr() and suppress automounting on that basis.
> 
> I'd prefer this one. Except I'd just call it LOOKUP_STAT to make it
> less cumbersome.
> 
> And then just have lstat/stat/xattr set that bit, and make it clear
> that that bit means "no automount".
> 

Maybe LOOKUP_NO_AUTOMOUNT would be better in that case?

-- 
Jeff Layton <jlayton@redhat.com>
