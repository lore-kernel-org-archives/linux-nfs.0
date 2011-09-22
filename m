Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43695 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab1IVQay (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 12:30:54 -0400
Received: by wyg34 with SMTP id 34so3153331wyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 09:30:53 -0700 (PDT)
In-Reply-To: <1316707443.3346.44.camel@perseus.themaw.net>
References: <20110922134510.24683.14576.stgit@warthog.procyon.org.uk> <1316707443.3346.44.camel@perseus.themaw.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 22 Sep 2011 09:30:33 -0700
Message-ID: <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Ian Kent <raven@themaw.net>
Cc: David Howells <dhowells@redhat.com>, miklos@szeredi.hu,
        viro@zeniv.linux.org.uk, jlayton@redhat.com, gregkh@suse.de,
        linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 22, 2011 at 9:04 AM, Ian Kent <raven@themaw.net> wrote:
>
> I haven't checked what the side effects would be but using the
> LOOKUP_DIRECTORY flag in walks that get caught by the removal of the
> LOOKUP_FOLLOW test in follow_automount() and retaining Miklos's original
> patch is probably a more natural solution IMO.

Ok, I do have to agree with that.

So instead of adding a new flag, let's just document a few *logical*
rules for what causes auto-mounting:

 - opening the mount-point itself with LOOKUP_DIRECTORY does so

   Logic: when you use LOOKUP_DIRECTORY, you expect to see the
*contents* of the mount-point.

 - looking something up *under* the mount-point does so.

   This may be obvious, but it actually has a non-obvious special
case: what about the pathname "mountpoint" vs "mountpoint/"

And I think the "LOOKUP_DIRECTORY" rule ends up automatically also
resolving that special case: when we have a slash at the end of the
last component, it not only implies that we care about the contents,
it will also automatically set LOOKUP_DIRECTORY.

So I'm getting more and more convinced that LOOKUP_DIRECTORY is
actually the right thing to trigger on. It automatically means that
"opendir()" on the mountpoint will do the right thing (because
O_DIRECTORY results in LOOKUP_DIRECTORY), and it automatically - and
very naturally - gives user processes the ability to choose whether
they want to see auto-monting or not ("path" doesn't get auto-mounted,
but "path/" does).

Yet at the same time it keeps the "stupid default behavior for
processes that only look at each directory entry and don't even think
about automounting" be the "don't auto-mount when not necessary"
behavior.

So: no new flag. Just make nfs4 use LOOKUP_DIRECTORY, and let's add
big documentation notes about this.

Ok?

                     Linus
