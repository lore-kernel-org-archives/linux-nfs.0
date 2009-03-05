From: Ni Wenjuan <niwj@cn.fujitsu.com>
Subject: NFS4ERR_SYMLINK  error
Date: Thu, 05 Mar 2009 17:32:24 +0800
Message-ID: <49AF9C28.8030603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49437 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752565AbZCEJdB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2009 04:33:01 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 78864170151
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2009 17:51:31 +0800 (CST)
Received: from fnst.cn.fujitsu.com (localhost.localdomain [127.0.0.1])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id n259Xr1B014473
	for <linux-nfs@vger.kernel.org>; Thu, 5 Mar 2009 17:33:53 +0800
Received: from [127.0.0.1] (unknown [10.167.141.247])
	by fnst.cn.fujitsu.com (Postfix) with ESMTPA id CB1C6DC41E
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2009 17:34:06 +0800 (CST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the result of newpynfs test case of  LINK4a .  if you link with target directoty
 is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.

THE LINK operation  don't list NFS4ERR_SYMLINK as valid errors in the spec. But
NFS4ERR_SYMLINK seems like a reasonable error.  Is this an oversight
in the spec, or something we need to fix?


