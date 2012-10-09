Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out01.mta.xmission.com ([166.70.13.231]:42682 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332Ab2JIUU5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 16:20:57 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel\@openvz.org" <devel@openvz.org>
References: <20121008105437.18668.99905.stgit@localhost.localdomain>
	<20121009193506.GA19680@fieldses.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90901A143@SACEXCMBX04-PRD.hq.netapp.com>
Date: Tue, 09 Oct 2012 13:20:48 -0700
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90901A143@SACEXCMBX04-PRD.hq.netapp.com>
	(Trond Myklebust's message of "Tue, 9 Oct 2012 19:49:46 +0000")
Message-ID: <87txu3bdnj.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v3] SUNRPC: set desired file system root before connecting local transports
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> writes:

> On Tue, 2012-10-09 at 15:35 -0400, J. Bruce Fields wrote:
>> Cc'ing Eric since I seem to recall he suggested doing it this way?

Yes.  On second look setting fs->root won't work. We need to change fs.
The problem is that by default all kernel threads share fs so changing
fs->root will have non-local consequences.

I very much believe we want if at all possible to perform a local
modification.

Changing fs isn't all that different from what devtmpfs is doing.

>> Seems OK to me, but maybe that swap_root should be in common code?  (Or
>> maybe we could use set_fs_root()?)
>> 
>> I'm assuming it's up to Trond to take this.--b.
>
> I'm reluctant to do that at this time since the original proposal was
> precisely that of export set_fs_root() and using it around the AF_LOCAL
> socket bind. That proposal was NACKed by Al Viro.

> If Al is OK with the idea of us creating a private version of
> set_fs_root, then I'd like to see an official Acked-by: that we can
> append to this commit.

Eric

