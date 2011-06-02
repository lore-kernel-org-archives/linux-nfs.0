Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41793 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932591Ab1FBKk7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2011 06:40:59 -0400
Received: from [10.30.3.27] ([10.30.3.27])
	(authenticated bits=0)
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p52Agm6j027621
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Jun 2011 14:42:49 +0400 (MSD)
Message-ID: <4DE768B7.8000301@parallels.com>
Date: Thu, 02 Jun 2011 14:40:55 +0400
From: Vasily Averin <vvs@parallels.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCHv2 0/2] minor cleanup of sunrpc/lockd debug
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

few minor cleanup of lockd/sunrpc debug messages

sunrpc: Use dprint_status() macro in call_decode()
lockd: properly convert be32 values in debug messages

v2 changes:
1) inline patches
2) lockd: properly convert be32 values in debug messages
	Using be32_to_cpu() instead ntohl()

Thank you,
	Vasily Averin
