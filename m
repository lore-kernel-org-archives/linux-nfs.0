Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759363Ab2CIUtq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 15:49:46 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29KnkE7017315
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 15:49:46 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 0/1] Kill SPKM3 auth method, addendum
Date: Fri,  9 Mar 2012 15:49:31 -0500
Message-Id: <1331326172-13296-1-git-send-email-simo@redhat.com>
In-Reply-To: <1331322586-4631-1-git-send-email-simo@redhat.com>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also kill the lipkey auth method which depends on the,
now completely defunct, spkm3 auth method.

Simo Sorce (1):
  Kill SPKM3: Remove also the dependent lipkey mechanism

 support/nfs/exports.c          |    3 ---
 utils/gssd/svcgssd_mech2file.c |    1 -
 utils/mount/nfs.man            |    7 ++-----
 utils/mount/nfsmount.c         |    6 ------
 4 files changed, 2 insertions(+), 15 deletions(-)

-- 
1.7.7.6

