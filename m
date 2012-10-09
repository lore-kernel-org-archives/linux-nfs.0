Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386Ab2JIWbz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Oct 2012 18:31:55 -0400
Date: Tue, 9 Oct 2012 18:31:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before
 connecting local transports
Message-ID: <20121009223139.GA25826@fieldses.org>
References: <20121008105437.18668.99905.stgit@localhost.localdomain>
 <20121009193506.GA19680@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90901A143@SACEXCMBX04-PRD.hq.netapp.com>
 <87txu3bdnj.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87txu3bdnj.fsf@xmission.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 09, 2012 at 01:20:48PM -0700, Eric W. Biederman wrote:
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> writes:
> 
> > On Tue, 2012-10-09 at 15:35 -0400, J. Bruce Fields wrote:
> >> Cc'ing Eric since I seem to recall he suggested doing it this way?
> 
> Yes.  On second look setting fs->root won't work. We need to change fs.
> The problem is that by default all kernel threads share fs so changing
> fs->root will have non-local consequences.

Oh, huh.  And we can't "unshare" it somehow?

Or, previously you suggested:

	- introduce sockaddr_fd that can be applied to AF_UNIX sockets,
	  and teach unix_bind and unix_connect how to deal with a second
	  type of sockaddr, AT_FD:
	  struct sockaddr_fd { short fd_family; short pad; int fd; }

	- introduce sockaddr_unix_at that takes a directory file
	  descriptor as well as a unix path, and teach unix_bind and
	  unix_connect to deal with a second sockaddr type, AF_UNIX_AT:
	  struct sockaddr_unix_at { short family; short pad; int dfd; char path[102]; }

Any other options?

> I very much believe we want if at all possible to perform a local
> modification.
> 
> Changing fs isn't all that different from what devtmpfs is doing.

Sorry, I don't know much about devtmpfs, are you suggesting it as a
model?  What exactly should we look at?

--b.
