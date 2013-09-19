Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab3ISU5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 16:57:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: nfs-utils patches for nfsv4.0 callbacks
Date: Thu, 19 Sep 2013 16:57:16 -0400
Message-Id: <1379624239-31199-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 callbacks over krb5 have been broken for a while.  With the
following three patches I've at least witnessed a succesful null
callback.

--b.

