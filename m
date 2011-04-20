Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52937 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab1DTXX6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 19:23:58 -0400
Date: Wed, 20 Apr 2011 19:23:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        "J. Bruce Fields" <bfields@redhat.com>, Greg KH <gregkh@suse.de>,
        linux-kernel@vger.kernel.org, stable@kernel.org,
        akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: nfsd bugfixes for 2.6.39
Message-ID: <20110420232342.GI15919@fieldses.org>
References: <BANLkTimN6L80e_oiJ_uqbLde2Cdnw5p45Q@mail.gmail.com>
 <20110418153236.GC20935@pad.home.fieldses.org>
 <87ipubwnj3.fsf@devron.myhome.or.jp>
 <8762qbwnf1.fsf@devron.myhome.or.jp>
 <87zknnv7id.fsf@devron.myhome.or.jp>
 <87vcybgt6u.fsf@devron.myhome.or.jp>
 <87hb9uhcre.fsf@devron.myhome.or.jp>
 <20110419204349.GB8228@fieldses.org>
 <87aafmgcvk.fsf@devron.myhome.or.jp>
 <20110419213331.GA9998@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110419213331.GA9998@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bugfixes for nfsd are available from the for-2.6.39 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.39

In particular, this should deal with the file leaks noticed by several
people.

--b.

J. Bruce Fields (1):
      nfsd4: fix struct file leak on delegation

OGAWA Hirofumi (1):
      nfsd4: Fix filp leak

Sachin Prabhu (1):
      Open with O_CREAT flag set fails to open existing files on non writable directories

 fs/nfsd/nfs4state.c |    3 ++-
 fs/nfsd/vfs.c       |    9 ++++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)
