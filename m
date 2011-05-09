Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60307 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754856Ab1EIVO4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 May 2011 17:14:56 -0400
Received: from drosapp.netapp.com ([10.58.49.10])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p49LEdOP008819
	for <linux-nfs@vger.kernel.org>; Mon, 9 May 2011 14:14:40 -0700 (PDT)
From: Weston Andros Adamson <dros@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: RFC: use scope from exchange_id to skip reclaim
Date: Mon,  9 May 2011 17:14:36 -0400
Message-Id: <1304975677-21419-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hey all,

I'd like comments on this patch.  I think that I'm right, but I'm not 100% 
about calling nfs4_state_start_reclaim_nograce() when server scopes don't match.

Thoughts?

-dros

