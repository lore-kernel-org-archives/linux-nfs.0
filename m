Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:34517 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758534Ab0JZSZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 14:25:07 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1PAoCn-00015R-AN
	for linux-nfs@vger.kernel.org; Tue, 26 Oct 2010 20:25:05 +0200
Received: from staff.ndchost.com ([204.10.36.76])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 20:25:05 +0200
Received: from mailinglists by staff.ndchost.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 26 Oct 2010 20:25:05 +0200
To: linux-nfs@vger.kernel.org
From: ShaunR <mailinglists@unix-scripts.com>
Subject: NFSv4 and portmap
Date: Tue, 26 Oct 2010 11:18:26 -0700
Message-ID: <ia761h$921$1@dough.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Everything i keep reading tells me that NFS4 does not need portmap but
for some reason on the NFS server ( CentOS 5.x ) i cannot get the nfs
services started unless portmap is running first.

On the server i modified /etc/sysconfig/nfs with the following options
MOUNTD_NFS_V1="no"
MOUNTD_NFS_V2="no"
RPCNFSDARGS="-N 2 -N 3 -U"

For some reason if i uncomment MOUNTD_NFS_v3="no" i get errors.

On the client, again a CentOS 5.x machine but with a newer custom built
kernel, If i do not start portmap then when i run mount it takes about 2
minutes for the filesystem to mount and i see the following messages in
/var/log/messages

Oct 26 10:25:30 host kernel: rpcbind: server localhost not responding,
timed out

If i start portmap, the mount command completed in a few seconds.


My goal here to is run/support NFSv4 Only.

~ShaunR

