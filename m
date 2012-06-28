Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35695 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275Ab2F1Hc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jun 2012 03:32:26 -0400
MIME-Version: 1.0
Date: Thu, 28 Jun 2012 15:32:26 +0800
Message-ID: <CACVXFVNwNfydVy5xOsAE=zgNbUU-rrMsyF3rQ605KDsqcYLcoA@mail.gmail.com>
Subject: [Bug -next] No files or directories under NFS mount point
From: Ming Lei <tom.leiming@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I found that there are no any files or directories displayed under
NFS mount point even though NFS mount is successful, but the
files do exist on NFS server.

[root@root]#mount
....
192.168.0.103:/home/tom/git/omap/nfs/ on /mnt/nfs type nfs
(rw,relatime,vers=3,rsize=524288,wsize=524288,namle
n=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.103,mountvers=3,mountproto=tcp,loc
al_lock=all,addr=192.168.0.103)

[root@root]#ls -l /mnt/nfs/
total 0


The problem is reproduced every time on 3.5-rc4-next, but no
such issue on 3.5-rc4.


Thanks,
-- 
Ming Lei
