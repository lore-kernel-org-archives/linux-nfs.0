Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759752Ab3DBRtM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 13:49:12 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnCPb014526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:12 -0400
Received: from willson.li.ssimo.org.com (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnB4F006259
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:11 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] Avoid DNS Reverse lookups when possible
Date: Tue,  2 Apr 2013 13:49:04 -0400
Message-Id: <1364924947-16985-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This new patchset obsoletes the patch sent earlier today.
The first and third patch are obvious.

The second patch implement a new command line option -N that takes
an on|off argument.

When 'on' is specified the RPC Server name as passed from the kernel
to rpc.gssd is check to see if it really is an actual IP address, if it
is the current code is executed (and reverse resolution happens),
otherwise the name used at the mount option is used directly w/o any
DNS resolution to construct the GSSAPI name.

Avoiding Reverse name resolution helps making the system work when PTR records
cannot be properly set on a network (because the amdin does not control DNS for
example) and also avoids a potential MITM attack (as explained early on in the
original patch thread).

Simo Sorce (3):
  Fix segfault when using -R option
  Avoid reverse resolution for server name
  Document new -N option

 utils/gssd/gss_util.h  |    2 ++
 utils/gssd/gssd.c      |   18 ++++++++++++++++--
 utils/gssd/gssd.man    |   11 ++++++++++-
 utils/gssd/gssd_proc.c |   25 +++++++++++++++++++++----
 4 files changed, 49 insertions(+), 7 deletions(-)

