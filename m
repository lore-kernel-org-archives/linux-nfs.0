Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37678 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab1FANhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jun 2011 09:37:03 -0400
Received: from [10.30.3.27] ([10.30.3.27])
	(authenticated bits=0)
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p51DclTq028223
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 1 Jun 2011 17:38:49 +0400 (MSD)
Message-ID: <4DE6407B.10000@parallels.com>
Date: Wed, 01 Jun 2011 17:36:59 +0400
From: Vasily Averin <vvs@parallels.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] minor cleanup of sunrpc/lockd debug
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

few minor cleanup of lockd/sunrpc debug messages

sunrpc: Use dprint_status() macro in call_decode()
lockd: properly convert be32 values in debug messages

Thank you,
	Vasily Averin
