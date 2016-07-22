Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40022 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488AbcGVRtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of EPERM
Date: Fri, 22 Jul 2016 13:48:49 -0400
Message-Id: <1469209736-6490-1-git-send-email-bfields@redhat.com>
In-reply-to: <C0BB3C96-A951-45D4-8599-B7FA50F1BA90@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

On Fri, Jul 22, 2016 at 11:13:20AM -0400, Oleg Drokin wrote:
> Hm, in fact indeed. I was just too worked up about the client side,
> but on the server side there was a real lookup already, so it does
> look workable.

So I end up with the following.  This is all (after your patch) pretty
trivial cleanup, but I think it's overdue for that code.

--b.


J. Bruce Fields (6):
  nfsd: remove redundant zero-length check from create
  nfsd: remove redundant i_lookup check
  nfsd: reorganize nfsd_create
  nfsd: remove unnecessary positive-dentry check
  nfsd: clean up bad-type check in nfsd_create_locked
  nfsd: drop unnecessary MAY_EXEC check from create

Oleg Drokin (1):
  nfsd: Make creates return EEXIST instead of EACCES

 fs/nfsd/nfs4proc.c |   3 +-
 fs/nfsd/nfsproc.c  |   7 +--
 fs/nfsd/vfs.c      | 131 ++++++++++++++++++++++++-----------------------------
 fs/nfsd/vfs.h      |   3 ++
 4 files changed, 66 insertions(+), 78 deletions(-)

-- 
2.7.4

