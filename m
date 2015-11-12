Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34272 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085AbbKLLnt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2015 06:43:49 -0500
Subject: [PATCH 0/2] FS-Cache: More miscellany
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cachefs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Thu, 12 Nov 2015 11:43:45 +0000
Message-ID: <20151112114344.22379.19320.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Attached are another couple of miscellaneous bits in FS-Cache and
CacheFiles:

 (1) Fix an uninitialised error value.

 (2) In MAINTAINERS, mark the mailing list as being moderated for
     non-subscribers.

These can also be found here:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache-fixes

David
---
Geert Uytterhoeven (2):
      FS-Cache: Add missing initialization of ret in cachefiles_write_page()
      MAINTAINERS: linux-cachefs@redhat.com is moderated for non-subscribers


 MAINTAINERS          |    4 ++--
 fs/cachefiles/rdwr.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

