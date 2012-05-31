Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:38845 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576Ab2EaS64 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2012 14:58:56 -0400
MIME-Version: 1.0
In-Reply-To: <20120531182457.GB25955@fieldses.org>
References: <20120531182457.GB25955@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 May 2012 11:58:34 -0700
Message-ID: <CA+55aFwGpVM2Dbe02gL5=cGJZ_t3b4PTAhqwrs5MHjsb5R6BaA@mail.gmail.com>
Subject: Re: nfsd changes for 3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2012 at 11:24 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Sorry this is a bit late.  In fact I still have a review backlog (at a
> minimum some bugfixes), so will send a second pull later.

Quite frankly, I'm not going to pull this without lots of explanations.

The VFS-level changes have no acks or sign-offs from anybody else, and
quite frankly, if I understand them correctly they look f*cking
disgusting. If I read them right, they break delegations of a file
(which can involve long waits for clients - no?) while holding on to
the directory inode lock (both directories for cross-inode renames).
Which seems to be a singularly idiotic thing to do and sounds to me
like a fundamental design mistake.

We simply don't do these kinds of VFS changes without having
discussions and acks from people, notably Al.

As to "second pull later" - if you haven't reviewed the code already,
it's damn well much too late in the merge window to do it now.

So quite frankly, this *all* looks like 3.6 material to me, and that's
assuming you can convince people that file-delegation breaking really
should happen with all lookups on the directory the file is in blocked
by the directory inode mutex in the first place. Or tell me I'm a
moron and I misread the patches and don't know what I'm talking about.

          Linus
