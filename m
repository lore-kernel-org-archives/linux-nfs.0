Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:38288 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbcD0PhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2016 11:37:10 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 0/2] Add multihostname support for NFSv4.1,2
Date: Wed, 27 Apr 2016 11:36:45 -0400
Message-ID: <1461771407-16423-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RFC patchset

Main question: Do we want to use multiple hostnames on the mount command to
   communicate the NFSv4.1 session trunking addresses, or only use (yet
   to be coded) fs_locations_info?

The multiple hostnames on the mount command are added to a new multiaddr
option and passed to the kernel for consumption.

This code requires the kernel "Version 3 NFSV4.1,2 session trunking"
patch set.

If we want to keep the multiple hostnames on the mount command method of
expressing NFSv4.1 session trunking addresses, we should fix this:

- v3 mounts with multiple hostnames succeeds but adds an mtab dev entry that
omits the ":/<exported dir> and so prints a warning at umount.
- need to update the manpage

-->Andy

Andy Adamson (2):
  NFS parse NFSv4 multiple hostnames
  NFS add multiaddr mount option

 utils/mount/parse_dev.c | 30 +++++++++++++++--------
 utils/mount/parse_dev.h |  2 +-
 utils/mount/stropts.c   | 63 ++++++++++++++++++++++++++++++++++++++++++++++++-
 utils/mount/utils.c     |  2 +-
 4 files changed, 84 insertions(+), 13 deletions(-)

-- 
1.8.3.1

