Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f176.google.com ([209.85.212.176]:43721 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442AbaJUOMv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2014 10:12:51 -0400
Message-ID: <5446682C.50201@electrozaur.com>
Date: Tue, 21 Oct 2014 17:05:32 +0300
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
To: Linus Torvalds <torvalds@linux-foundation.org>,
        open-osd <osd-dev@open-osd.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        linux-scsi <linux-scsi@vger.kernel.org>
Subject: [GIT PULL] osd: Boaz Harrosh - change of email
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sir Linus

A small administrative stuff, was on vacation and the old email bounced on me.
I was hoping to still make the 3 weeks merge window, but it was 2 weeks at the
end.
Your call if to make this wait for next window. Needless to say that it is
ZERO risk, just change of email.

Based on commit [bfe01a5b] Linux 3.17

3 patches available in the git repository at:

  git://git.open-osd.org/linux-open-osd.git for-linus

for you to fetch changes up to 1fa3a002b2546c42c343c77c144871285896ced5:

  Boaz Harrosh - fix email in Documentation (2014-10-19 20:36:36 +0300)

----------------------------------------------------------------
Boaz Harrosh (3):
      MAINTAINERS: Change Boaz Harrosh's email
      Boaz Harrosh - Fix broken email address
      Boaz Harrosh - fix email in Documentation

 Documentation/scsi/osd.txt          | 3 +--
 MAINTAINERS                         | 2 +-
 drivers/scsi/osd/Kbuild             | 2 +-
 drivers/scsi/osd/Kconfig            | 2 +-
 drivers/scsi/osd/osd_debug.h        | 2 +-
 drivers/scsi/osd/osd_initiator.c    | 4 ++--
 drivers/scsi/osd/osd_uld.c          | 4 ++--
 fs/exofs/Kbuild                     | 2 +-
 fs/exofs/common.h                   | 2 +-
 fs/exofs/dir.c                      | 2 +-
 fs/exofs/exofs.h                    | 2 +-
 fs/exofs/file.c                     | 2 +-
 fs/exofs/inode.c                    | 2 +-
 fs/exofs/namei.c                    | 2 +-
 fs/exofs/ore.c                      | 4 ++--
 fs/exofs/ore_raid.c                 | 2 +-
 fs/exofs/ore_raid.h                 | 2 +-
 fs/exofs/super.c                    | 2 +-
 fs/exofs/symlink.c                  | 2 +-
 fs/exofs/sys.c                      | 2 +-
 fs/nfs/objlayout/objio_osd.c        | 2 +-
 fs/nfs/objlayout/objlayout.c        | 2 +-
 fs/nfs/objlayout/objlayout.h        | 2 +-
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c | 2 +-
 include/linux/pnfs_osd_xdr.h        | 2 +-
 include/scsi/osd_initiator.h        | 2 +-
 include/scsi/osd_ore.h              | 2 +-
 include/scsi/osd_protocol.h         | 4 ++--
 include/scsi/osd_sec.h              | 2 +-
 include/scsi/osd_sense.h            | 2 +-
 include/scsi/osd_types.h            | 2 +-
 31 files changed, 35 insertions(+), 36 deletions(-)

Thanks, have a good Kernel Cycle
Boaz
