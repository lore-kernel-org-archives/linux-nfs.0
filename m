Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbaKYRFj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 12:05:39 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH] rpcbind: systemd socket activation (v2)
Date: Tue, 25 Nov 2014 12:05:32 -0500
Message-Id: <1416935133-7104-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is based on a patch originally posted by Lennart Poettering:
<http://permalink.gmane.org/gmane.linux.nfs/33774>.

That patch was not merged due to the lack of a shared library and
as systemd was seen to be too Fedora specific.

Systemd now provides a shared library, and it is (or very soon will
be) the default init system on all the major Linux distributions.

This version of the patch has three changes from the original:

 * It uses the shared library.
 * It comes with unit files.
 * It is rebased on top of master.

Please review the patch with "git show -b" or otherwise ignoring the
whitespace changes, or it will be extremely difficult to read.

v5: incorporated comments on the PKG_CHECK_MODULES macro.

v4: reorganized the changes to make the diff easier to read
	remove systemd scripts.

v3: rebase
	fix typos
	listen on /run/rpcbind.sock, rather than /var/run/rpcbind.sock (the
	latter is a symlink to the former, but this means the socket can be
	created before /var is mounted)
	NB: this version has been compile-tested only as I no longer use
	rpcbind myself
v2: correctly enable systemd code at compile time
	handle the case where not all the required sockets were supplied
	listen on udp/tcp port 111 in addition to /var/run/rpcbind.sock
	do not daemonize

Tom Gundersen (1):
  rpcbind: add support for systemd socket activation

 Makefile.am   |  6 +++++
 configure.ac  | 12 +++++++++
 src/rpcbind.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 93 insertions(+), 6 deletions(-)

-- 
1.9.3

