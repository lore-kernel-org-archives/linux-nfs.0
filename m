Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:45960 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755665AbaCLRrP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 13:47:15 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so10881804iec.37
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 10:47:14 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id kb5sm60077881igb.1.2014.03.12.10.47.13
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Mar 2014 10:47:14 -0700 (PDT)
Subject: [PATCH 0/2] command line IPv6 support for exportfs
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 12 Mar 2014 13:47:11 -0400
Message-ID: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Though /etc/exports can contain IPv6 literals as client names, the
exportfs command doesn't allow an IPv6 literal when adding or
removing a temporary export.

  exportfs [-u] client:/path

If "client" is an IPv6 presentation address, it contains colons.
The problem is that exportfs already uses a colon to separate the
client identifier from the export pathname.

To escape colons in the client name, adopt the same mechanism that
is used for mount.nfs.  Users wrap IPv6 literals in square brackets.

exportfs has to be a little more complicated than mount.nfs,
however.  It must still be able to distinguish hostname wildcards
that use brackets, and be able to deal with network address
prefixes.

With this patch series,

  [abc]-machine.example.org:/export

  192.168.76.16:/share

  [2604:8800:100:81fc:82ee:73ff:fe43:d64f]:/export/home

  [fe80::]/64:/var/tmp

are now all accepted by exportfs.

---

Chuck Lever (2):
      exportfs: Refactor exportfs() and unexportfs()
      exportfs: Support raw IPv6 addresses with "client:/path"


 utils/exportfs/exportfs.c   |  134 ++++++++++++++++++++++++++++++++++++-------
 utils/exportfs/exportfs.man |   16 +++++
 2 files changed, 127 insertions(+), 23 deletions(-)

-- 
Chuck Lever
