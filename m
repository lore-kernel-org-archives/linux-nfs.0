Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:37534 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965371Ab0CORva (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 13:51:30 -0400
Received: by qw-out-2122.google.com with SMTP id 9so784198qwb.37
        for <linux-nfs@vger.kernel.org>; Mon, 15 Mar 2010 10:51:30 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two short fixes for sm-notify
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 15 Mar 2010 13:51:27 -0400
Message-ID: <20100315174453.2586.40876.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

These address two minor shortcomings when sending SM_NOTIFY requests
during reboot recovery.  Please consider these for the next nfs-utils
release.

---

Chuck Lever (2):
      sm-notify: Send fully-qualified and unqualified mon_names
      sm-notify: Use my_name when sending SM_NOTIFY requests


 utils/statd/sm-notify.c   |   62 ++++++++++++++++++++++++++++++++++++---------
 utils/statd/sm-notify.man |   28 +++++++++-----------
 utils/statd/statd.man     |   14 +---------
 3 files changed, 64 insertions(+), 40 deletions(-)

-- 
Chuck Lever
