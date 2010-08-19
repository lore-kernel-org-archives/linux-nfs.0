Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22048 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab0HSP2p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:28:45 -0400
From: andros@netpp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] rename getdeviceinfo and layoutget proc and xdr 
Date: Thu, 19 Aug 2010 11:27:52 -0400
Message-Id: <1282231677-4412-1-git-send-email-andros@netpp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Match current nfs operation xdr and proc naming.

Applies on top of [PATCH 0/11] pnfs-submit rename pnfs_layout_type

-->Andy
