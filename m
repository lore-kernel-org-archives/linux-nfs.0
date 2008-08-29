From: Ricardo Santos <xscorpionbr-/E1597aS9LRfJ/NunPodnw@public.gmane.org>
Subject: directory attribute cache on NFS4 client
Date: Fri, 29 Aug 2008 13:42:05 +0000 (UTC)
Message-ID: <loom.20080829T132559-688@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:46668 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758093AbYH2NpG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 09:45:06 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KZ4He-0007GK-SQ
	for linux-nfs@vger.kernel.org; Fri, 29 Aug 2008 13:45:03 +0000
Received: from viper.litoral.com.br ([200.155.112.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 29 Aug 2008 13:45:02 +0000
Received: from xscorpionbr by viper.litoral.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 29 Aug 2008 13:45:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First, some info:

NFS4 Client: Fedora 9 - 2.6.25.9-76.fc9.i686
NFS4 Server: Fedora 9 - 2.6.25.6-55.fc9.i686
exportfs: rw,fsid=0,no_root_squash,async
mount: rw,bg,retry=1,timeo=30,rsize=8192,wsize=8192

Both on a local network

The Server act as a filer to a webhosting solution. I have 2 clients (FTP and
WebServer). When someone upload and overwrite a file on FTP, normally it do it:

- UPLOAD fileA.tmp
- DELETE fileA
- RENAME fileA.tmp fileA

This operation changes the inode for "fileA" and the WebServer doesn't see the
changes, still getting the old file (old inode).

After upload, if I do a "ls -la /path/path/fileA", it returns the old stats
(inode, mtime...). But if I do a "ls -la /path/path/" this will refresh info,
and get the file correctly.

I've tried the "acdirmin" and "acdirmax" defined to 0, but didn't work. I tried
too "noac", really works but the performance cost is expensive.

I really wouldn't like back to NFS3... :)

