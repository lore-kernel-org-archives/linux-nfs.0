Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57390 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601Ab2DXFrk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 01:47:40 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Date: Tue, 24 Apr 2012 15:46:38 +1000
Subject: [PATCH 0/6] fix some problems with v4root handling in mountd
Cc: linux-nfs@vger.kernel.org
Message-ID: <20120424054003.20130.16209.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First I'd like to say that I love seeing comments that explain the
code..  What way when the code does something different to the
comment, I can be sure I'm on to something :-)

If I have exports:

 /  *(rw,no_root_squash)
 /home 192.168.1.2(rw,no_root_squash)

Then I want to export 'root' to everything (on my side of a firewall)
but '/home' only to one machine.
However this doesn't work for host 192.168.1.2.
If I try to mount '/' with NFSv3, it fails.
If I try to mount '/' with NFSv4, then it works but we only see
"home" in the mounted "/".

The problem is that the export of "/home" causes a V4ROOT export
of "/" to be created for 192.168.1.2 and as MCL_SUBNETWORK comes
before MCL_WILDCARD, the V4ROOT export wins and the other wildcard
export isn't even tried.

So the following patches:
 1/ fix the NFSv4 mount case so that we really see '/' and not a pseudo
    '/'.  This is the case where the comment says the right thing
    but the code doesn't.

 2/ fix 'mountd' lookup for NFSv2/v3 so they successfully mount
    the real export, and don't fail because only the V4ROOT export
    was found,

 3/ Fix a similar ordering problem in nfsd_fh.  Without this an
    NFSv4 client might see the V4ROOT export for '/' rather than
    the explicitly exported export.

 4/ Set a useful ttl on V4ROOT exports so they don't need to
    constantly be refreshed, an
  
 5/ fix a buglet which didn't cause any of these problems but
    certainly looks wrong.

Enjoy :-)

NeilBrown

---

Neil Brown (6):
      v4_root_add_parents: remove a possible buffer overflow.
      v4root: set the time-to-live for V4ROOT exports to the DEFAULT.
      v4set_root: force "fsid=0" for all exports of '/'
      nfsd_fh: if two exports are possible, choose the one without V4ROOT
      auth_authenticate_newcache: prefer non-V4ROOT export over V4ROOT exports.
      lookup_export: really prefer nonV4ROOT exports.


 utils/mountd/auth.c   |    7 +++----
 utils/mountd/cache.c  |   21 +++++++++++++++++----
 utils/mountd/v4root.c |   12 ++++++++++--
 3 files changed, 30 insertions(+), 10 deletions(-)

-- 
Signature

