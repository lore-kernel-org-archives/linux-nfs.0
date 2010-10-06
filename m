Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097Ab0JGNK7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 09:10:59 -0400
Received: from localhost.localdomain (laino1-lxp.hq.netapp.com [10.58.48.170])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o97DAgW8017616
	for <linux-nfs@vger.kernel.org>; Thu, 7 Oct 2010 06:10:44 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] pnfs-submit: misc fixes in CB_LAYOUTRECALL and layout stateid code
Date: Wed,  6 Oct 2010 16:35:13 -0400
Message-Id: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Preparing for second submission wave, here are some misc fixes to the
LAYOUTRETURN and callback code, that all apply to the top of Benny's
pnfs-submit branch

Fred

