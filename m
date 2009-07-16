From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: [PATCH 0/4] Kill PROC macro from NLM
Date: Thu, 16 Jul 2009 17:27:55 +0800
Message-ID: <4A5EF29B.1050100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60852 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754092AbZGPJ2w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 05:28:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In NFSv4 and rpcb_clnt, the PROC macro was killed.
I think maybe we should kill it from NLM too.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
   NLM: Kill PROC macro from NLMv1 and NLMv3 server procedures.
   NLM: Kill PROC macro from NLMv4 server procedures.
   NLM: Kill PROC macro from NLMv1 and NLMv3 client procedures.
   NLM: Kill PROC macro from NLMv4 client procedures.

Best Regard.
 Bian Naimeng

