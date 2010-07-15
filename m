Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab0GOU6a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 16:58:30 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] pnfs-submit use latest layout stateid 
Date: Thu, 15 Jul 2010 16:58:50 -0400
Message-Id: <1279227534-3226-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Set the layout stateid from an open stateid in layoutget iff the layout stateid
is zero.

Get the layout stateid from the layout in the xdr layer for layoutget and
layoutreturn so that the latest stateid is used. Fixes a bug where a retry due
to NFS4ERR_OLD_STATEID (and any retry) will use the old stateid.

0001-SQUASHME-pnfs-submit-get-layoutget-stateid-from-layo.patch
0002-SQUASHME-pnfs-submit-get-layoutreturn-stateid-from-l.patch

Remove unnecessary fields.

0003-SQUASHME-pnfs-submit-remove-unnecessary-layoutreturn.patch
0004-SQUASHME-pnfs-submit-remove-unnecessary-layoutget-fi.patch

Tested

CONFIG_NFS_V4_1 set

Connectathon passes

-->Andy

