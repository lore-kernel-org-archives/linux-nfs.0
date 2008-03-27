From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] RTT computation fix-ups
Date: Thu, 27 Mar 2008 16:13:56 -0400
Message-ID: <20080327201019.4587.77496.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:46403 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757183AbYC0UOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 16:14:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

What do you think of these changes to how the RPC client measures request
round-trip times?

-- 
corporate:    <chuck dot lever at oracle dot com>
