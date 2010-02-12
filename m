Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36630 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829Ab0BLSZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 13:25:54 -0500
From: andros@netapp.com
To: pnfs@linux-nfs.org
Cc: linux-nfs@vger.kernel.org
Subject: pnfs: use mds pseudoflavor for ds
Date: Fri, 12 Feb 2010 13:24:47 -0500
Message-Id: <1265999088-3507-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


This patch enables Kerberos connections (or whatever flavor is established
to the MDS) to the Data Servers.

Passes connectathon against pNFS/GFS2.

-->Andy
