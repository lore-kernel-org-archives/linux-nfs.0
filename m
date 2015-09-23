Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64405 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbbIWG0r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 02:26:47 -0400
From: Shan Hai <shan.hai@windriver.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1] nfs-utils: fix a segfault caused by improper usage of RPC interface
Date: Wed, 23 Sep 2015 14:24:33 +0800
Message-ID: <1442989474-211924-1-git-send-email-shan.hai@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch fixes a segfault in the statd when there are lots of NFS clients
try to mount a single NFS export. 

Thanks
Shan Hai
