Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f170.google.com ([209.85.215.170]:57480 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbaCDHiI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 02:38:08 -0500
Received: by mail-ea0-f170.google.com with SMTP id g15so138119eak.15
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 23:38:07 -0800 (PST)
From: Noam Meltzer <noam@primarydata.com>
To: noam@primarydata.com, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
Subject: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
Date: Tue,  4 Mar 2014 09:37:51 +0200
Message-Id: <1393918676-20865-1-git-send-email-noam@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello sssd-devel & linux-nfs,

This is v2 of the patch set. It is now sent to linux-nfs as weel, following
Steve Dickson request.

The code in the next 5 patches implements the design document:
https://fedorahosted.org/sssd/wiki/DesignDocs/rpc.idmapd%20plugin

The changes in the code (compared to v1) are following the review done in
sssd-devel.
I believe that there are still two items in dispute (no final verdict was given
in the sssd mailing list) but this new patch set will give a chance to have a
cleaner look on things.

--

Noam Meltzer
Linux Software Engineer
PRIMARY DATA

P.O. Box 12650, Herzliya Pituach 4673300
9 Hamenofim St. Akerstein Towers, Tower A, 5th fl. Herzliya

Office: +972-77-8981888 | Fax: +972-3-7617140 | Mobile: +972-54-5873843

Email: noam@primarydata.com


--

Noam Meltzer (5):
  NEW CLIENT: plugin for NFSv4 rpc.idmapd
  NFSv4 client: (private) headers from libnfsidmap
  NFSv4 client: add to build system
  NFSv4 client: man page
  NFSv4 client: add to RPM spec

 Makefile.am                            |  19 ++
 configure.ac                           |  10 +
 contrib/sssd.spec.in                   |   8 +
 src/conf_macros.m4                     |  30 ++
 src/external/libnfsidmap.m4            |  17 +
 src/man/Makefile.am                    |   4 +-
 src/man/include/seealso.xml            |   4 +
 src/man/sss_rpcidmapd.5.xml            |  97 ++++++
 src/sss_client/common.c                |   5 +
 src/sss_client/nfs/nfsidmap_internal.h |  78 +++++
 src/sss_client/nfs/sss_nfs_client.c    | 569 +++++++++++++++++++++++++++++++++
 src/sss_client/sss_cli.h               |   2 +
 12 files changed, 842 insertions(+), 1 deletion(-)
 create mode 100644 src/external/libnfsidmap.m4
 create mode 100644 src/man/sss_rpcidmapd.5.xml
 create mode 100644 src/sss_client/nfs/nfsidmap_internal.h
 create mode 100644 src/sss_client/nfs/sss_nfs_client.c

-- 
1.8.5.3

