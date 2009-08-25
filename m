From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 0/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
 option are set (vers-02)
Date: Tue, 25 Aug 2009 13:52:27 -0400
Message-ID: <4A9424DB.2040303@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755329AbZHYRwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 13:52:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is an update of the patch I posted yesterday... It turns
out the /etc/mtab was not getting updated with the correct 
files system type which in turn causing the remote mountd to
be called on v4 mounts... So the second patch deals with that issue... 

Both of these patches can be found on the "mount_vers4-r2" branch on 
my experiential git tree:
     git://linux-nfs.org/~steved/nfs-utils-exp.git


</rant>
Why we continue to use mtab instead of /proc/mounts on umount is a 
bit mind boggling... plus writing to the '/etc' directory is 
just wrong... IMHO... espically in a read-only root environment.. 
</rant> 


steved.

