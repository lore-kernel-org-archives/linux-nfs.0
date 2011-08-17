Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38518 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919Ab1HQUyU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Aug 2011 16:54:20 -0400
Date: Wed, 17 Aug 2011 16:54:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: two more minor pynfs patches
Message-ID: <20110817205419.GC17025@fieldses.org>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
 <20110809203008.GA18098@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110809203008.GA18098@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have more changes available from:

  git://linux-nfs.org/~bfields/pynfs.git master

Main changes since the last pull request are to require a
NFS4ERR_SYMLINK return for OPEN of non-regular files, and to allow it
(as opposed to INVAL or ISDIR or whatever) for various operations on
symlinks.  I think that's correct.

--b.

J. Bruce Fields (19):
      CLNT: provide new_client_session shortcut
      CLNT: send RECLAIM_COMPLETE when required
      Share showresults.py between 4.0 and 4.1
      Make top-level setup.py set up nfs4.0 as well
      Merge top-level READMEs
      Share testmod.py between nfs4.0 and nfs4.1
      server41tests: separate lookup from rename
      read+write+readwrite open test
      check another odd linux server case
      Move nfs4.0/lib/nfs4/* to nfs4.0/
      Fix README setup instructions
      Warn that pynfs is not authoritative
      4.0 server tests: OPEN of special file should return SYMLINK
      4.0 server tests: allow SYMLINK for more tests
      4.0 server tests: check open result in OPEN29
      4.1 server tests: RNM2a should allow NFS4ERR_SYMLINK
      4.1 server tests: remove SEQ14
      4.0 server tests: fix OPEN29
      4.0 server tests: fix DELEG6 for short leases

 README                                             |   24 +-
 README-4.1                                         |    8 -
 nfs4.0/.gitignore                                  |    4 +-
 nfs4.0/lib/nfs4/__init__.py                        |    1 -
 nfs4.0/lib/ops_gen.py                              |    4 +-
 nfs4.0/lib/testmod.py                              |  417 +-------------------
 nfs4.0/{lib/nfs4 => }/nfs4.x                       |    0
 nfs4.0/{lib/nfs4 => }/nfs4acl.py                   |    4 +-
 nfs4.0/nfs4client.py                               |    8 +-
 nfs4.0/{lib/nfs4 => }/nfs4lib.py                   |    0
 nfs4.0/nfs4server.py                               |   12 +-
 nfs4.0/{lib/nfs4 => }/nfs4state.py                 |    0
 nfs4.0/{lib/nfs4 => }/servertests/__init__.py      |    0
 nfs4.0/{lib/nfs4 => }/servertests/environment.py   |    6 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_access.py     |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_close.py      |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_commit.py     |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_compound.py   |    6 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_create.py     |    8 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_delegation.py |    8 +-
 .../{lib/nfs4 => }/servertests/st_fslocations.py   |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_getattr.py    |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_getfh.py      |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_gss.py        |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_link.py       |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_lock.py       |   21 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_lockt.py      |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_locku.py      |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_lookup.py     |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_lookupp.py    |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_nverify.py    |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_open.py       |   40 ++-
 .../{lib/nfs4 => }/servertests/st_openconfirm.py   |    4 +-
 .../{lib/nfs4 => }/servertests/st_opendowngrade.py |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_putfh.py      |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_putpubfh.py   |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_putrootfh.py  |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_read.py       |    6 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_readdir.py    |   12 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_readlink.py   |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_reboot.py     |    2 +-
 .../nfs4 => }/servertests/st_releaselockowner.py   |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_remove.py     |    6 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_rename.py     |    8 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_renew.py      |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_replay.py     |    4 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_restorefh.py  |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_savefh.py     |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_secinfo.py    |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_setattr.py    |    6 +-
 .../{lib/nfs4 => }/servertests/st_setclientid.py   |    2 +-
 .../nfs4 => }/servertests/st_setclientidconfirm.py |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_spoof.py      |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_verify.py     |    2 +-
 nfs4.0/{lib/nfs4 => }/servertests/st_write.py      |    6 +-
 nfs4.0/setup.py                                    |    5 +-
 nfs4.0/testserver.py                               |    6 +-
 nfs4.1/nfs4client.py                               |    6 +
 nfs4.1/server41tests/environment.py                |   20 +-
 nfs4.1/server41tests/st_block.py                   |   16 +-
 nfs4.1/server41tests/st_open.py                    |   23 +-
 nfs4.1/server41tests/st_rename.py                  |  112 ++----
 nfs4.1/server41tests/st_secinfo.py                 |    6 +-
 nfs4.1/server41tests/st_sequence.py                |   35 +--
 nfs4.1/showresults.py                              |   74 ----
 setup.py                                           |    6 +-
 nfs4.0/showresults.py => showresults.py            |    4 +-
 67 files changed, 256 insertions(+), 748 deletions(-)
 delete mode 100644 README-4.1
 delete mode 100644 nfs4.0/lib/nfs4/__init__.py
 mode change 100644 => 120000 nfs4.0/lib/testmod.py
 rename nfs4.0/{lib/nfs4 => }/nfs4.x (100%)
 rename nfs4.0/{lib/nfs4 => }/nfs4acl.py (99%)
 rename nfs4.0/{lib/nfs4 => }/nfs4lib.py (100%)
 rename nfs4.0/{lib/nfs4 => }/nfs4state.py (100%)
 rename nfs4.0/{lib/nfs4 => }/servertests/__init__.py (100%)
 rename nfs4.0/{lib/nfs4 => }/servertests/environment.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_access.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_close.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_commit.py (96%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_compound.py (96%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_create.py (97%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_delegation.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_fslocations.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_getattr.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_getfh.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_gss.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_link.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_lock.py (97%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_lockt.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_locku.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_lookup.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_lookupp.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_nverify.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_open.py (93%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_openconfirm.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_opendowngrade.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_putfh.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_putpubfh.py (96%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_putrootfh.py (88%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_read.py (97%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_readdir.py (97%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_readlink.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_reboot.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_releaselockowner.py (88%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_remove.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_rename.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_renew.py (97%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_replay.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_restorefh.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_savefh.py (91%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_secinfo.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_setattr.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_setclientid.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_setclientidconfirm.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_spoof.py (98%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_verify.py (99%)
 rename nfs4.0/{lib/nfs4 => }/servertests/st_write.py (98%)
 delete mode 100755 nfs4.1/showresults.py
 mode change 100644 => 100755 setup.py
 rename nfs4.0/showresults.py => showresults.py (94%)
