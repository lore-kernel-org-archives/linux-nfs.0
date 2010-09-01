Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from python-06.easyrencontre.com ([91.199.255.56]:43505 "EHLO
	mail.easyflirt.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab0IAMYj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 08:24:39 -0400
Received: from [127.0.0.1] (office.easyrencontre.com [78.155.152.6])
	by mail.easyflirt.com (Postfix) with ESMTPSA id 67E806365B1
	for <linux-nfs@vger.kernel.org>; Wed,  1 Sep 2010 14:17:46 +0200 (CEST)
Message-ID: <4C7E4469.70807@duchatelet.net>
Date: Wed, 01 Sep 2010 14:17:45 +0200
From: Greg <greg-sys@duchatelet.net>
To: linux-nfs@vger.kernel.org
Subject: Relocate NFS root FS for maintenance
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  Hi,

I don't know if it is the good place to ask for such a problem, if not 
please apologize.

I have a pseudo active/active NFSv4 configuration: 2 NFSv4 servers 
(1:1.1.2-6lenny1), exporting 3 filesystems. Each filesystem are 
connected to a SAN volume, via iscsi and multipath.

filer-01 :
/var/local                      
10.0.0.0/16(rw,fsid=0,crossmnt,insecure,async,no_subtree_check)
/var/local/large            
10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=3)

filer-02 :
/var/local                      
10.0.0.0/16(rw,fsid=0,crossmnt,insecure,async,no_subtree_check)
/var/local/small           
10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=1)
/var/local/medium      
10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=2)

filer-01 share a volume on the first SAN, filer-02 share 2 volumes on 
the second SAN.

I have to do a firmware upgrade on the SANs, so I have to umount 
/var/local/* on the nfs servers. On way could be to relocate NFS root FS 
from /var/local to /var/maintenance with empty directories large, medium 
and small
But how to do that ? I try to change /etc/exports then exportfs -rvf, 
but got "Stale NFS file handle" on clients...

If not, is there a better way to do that, without to shutdown NFS servers ?

-- 
Greg

