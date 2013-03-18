Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:62680 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751136Ab3CRHPx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Mar 2013 03:15:53 -0400
Message-ID: <5146BE38.2060004@cn.fujitsu.com>
Date: Mon, 18 Mar 2013 15:11:52 +0800
From: chenditang <chendt.fnst@cn.fujitsu.com>
MIME-Version: 1.0
To: bhalevy@tonian.com
CC: linux-nfs@vger.kernel.org, LINE <fnst-xmlinux@cn.fujitsu.com>
Subject: pnfs: WRITE operation will not send LAYOUTCOMMI OP to MDS if use
 filelayout
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the recent pnfs kernel versions, WRITE operation will not send
LAYOUTCOMMI OP to MDS if use filelayout.

In nfs_write_rpcsetup function, the value of the variable 'stable' will
always be NFS_FILE_SYNC(ncommit is 0). so NFS_INO_LAYOUTCOMMIT 
flag will not be set.

The value of the variable ncommit' will be ++ in the later process
(nfs_writeback_release_common function).


Thanks!

