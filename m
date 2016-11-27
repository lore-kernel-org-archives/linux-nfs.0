Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:51436 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752681AbcK0G1Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2016 01:27:24 -0500
From: Tom Haynes <loghyr@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs 00/12] Flex File support
Date: Sat, 26 Nov 2016 22:26:29 -0800
Message-ID: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I wanted to add client support for the flex file layout.

Note, I did not add pynfs as a flag because I didn't want to
mess up with any existing uses of it.

The other major change here is in closing all opened
files and destroying all clientids. With all the tests
which run against my server, there are no longer any
open files. There are however 11 clientids remaining.

I will track those down.

fwiw - these are in my staging branch at git://linux-nfs.org/~loghyr/pynfs.=
git

Tom Haynes (12):
  According to RFC7863, this is not an array
  Close the files opened in the OPEN tests
  Some more file closes to cleanup state on the server
  Get rid of the client records as well as the session records
  Really, really close those open temp files to remove state on the
    server
  Add xdr for Flex Files Layout Type
  Simple tests of the flex file layout type
  Add a check to see if NFS4ERR_OLD_STATEID is issued on concurrent
    layoutgets
  Check that the flex file access uid/gid are correct for the different
    iomodes
  FFLS1: Simulate LAYOUTSTATS for 20 small file creations
  Factor out checking seqid for flex file layouts
  Add layoutstats tests for flex files

 nfs4.1/nfs4client.py                        |   5 +-
 nfs4.1/server41tests/__init__.py            |   1 +
 nfs4.1/server41tests/environment.py         |   5 +
 nfs4.1/server41tests/st_current_stateid.py  |  36 +-
 nfs4.1/server41tests/st_debug.py            |  18 +-
 nfs4.1/server41tests/st_flex.py             | 594 ++++++++++++++++++++++++=
++++
 nfs4.1/server41tests/st_open.py             |  29 +-
 nfs4.1/server41tests/st_reclaim_complete.py |   4 +
 nfs4.1/server41tests/st_rename.py           |   4 +
 nfs4.1/server41tests/st_secinfo.py          |  20 +-
 nfs4.1/server41tests/st_sequence.py         |   8 +
 nfs4.1/testmod.py                           |   1 +
 nfs4.1/xdrdef/nfs4.x                        |  99 ++++-
 13 files changed, 812 insertions(+), 12 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_flex.py

--=20
2.3.6

