Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36877 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab1EXKw1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 06:52:27 -0400
Message-ID: <4DDB8DD1.20101@panasas.com>
Date: Tue, 24 May 2011 13:52:01 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHS 0/3] Some more bugs in latest code + please help with last
 problem
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


I'm sending some more fixes.

After launch I will re-send all the fixes needed ontop of Benny's
last tree as SQUASHMEs. One SQUASHME for each patch in the set that
needs one. 

Last sent fixes will have conflicts with newest code. So these re-sent
will resolve that.

With this code, I'm able to use the global-device-cache the way It
was with the old one. Also including all the fixes I'm able to do
IO, and checkout a git tree!

*BUT*: Currently IO is very very slow, because wsize/rsize is set
       to default 64k which is just one strip_unit for default
       objects. I used to set server->w/rsize on .set_layoutdriver
       but Benny removed that. What do you guys want to do with this?
       I can see to options:
       1. Return the .set_layoutdriver where ld can set defaults
          the way it likes it.
       2. If pnfs is used set w/rsize to MAX_UINT and let pg_test
          cap the sizes as see fit.

       Please advise?

For now these:
	SQUSHME: pnfs: BUG in _deviceid_purge_client
	pnfs: layout_driver MUST set free_deviceid_node if using dev-cache
	SQUASHME: pnfs-obj: objlayout wants to cache devices until unmount

Thanks
Boaz

