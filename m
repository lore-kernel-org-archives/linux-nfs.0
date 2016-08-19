Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39249 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754809AbcHSCEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 22:04:10 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 19 Aug 2016 11:45:56 +1000
Subject: [PATCH 0/2] nfs-utils patches relating to server startup
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Message-ID: <147157095612.26568.14161646901346011334.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two patches for recently discussed functionality.
Both revert earlier patches and provide a more complete
solution.

The first adds a new program.  I've placed this in "systemd/" rather
than "utils/something" because that seemed to make sense.  Is it
inelegant putting code in a directory with unit files?

I don't do a lot of automake coding so if someone were to make sure I
didn't do anything non-standard in the Makefile.am, that would be
appreciated.

Thanks,
NeilBrown

---

NeilBrown (2):
      systemd: improve ordering between nfs-server and various mounts
      mount: RPC_PROGNOTREGISTERED should not be a permanent error


 systemd/Makefile.am            |    8 ++
 systemd/nfs-server-generator.c |  144 ++++++++++++++++++++++++++++++++++++++++
 systemd/nfs-server.service     |    3 -
 utils/mount/stropts.c          |    7 +-
 4 files changed, 155 insertions(+), 7 deletions(-)
 create mode 100644 systemd/nfs-server-generator.c

--
Signature

