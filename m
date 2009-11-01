From: Warpme <warpme-h7QdYz1kt/Q@public.gmane.org>
Subject: Issue with stalled NFS
Date: Sun, 01 Nov 2009 23:00:18 +0100
Message-ID: <4AEE04F2.2070400@o2.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040407020504020509070805"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:58161 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbZKAWA6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Nov 2009 17:00:58 -0500
Received: from mailout1.go2.pl (mailout1.go2.pl [193.17.41.11])
	by tur.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id F3CF3230B7D
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2009 23:01:01 +0100 (CET)
Received: from mailout1.go2.pl (unknown [10.0.0.104])
	by mailout1.go2.pl (Postfix) with ESMTP id A31B330010
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2009 23:00:20 +0100 (CET)
Received: from unknown (unknown [10.0.0.74])
	by mailout1.go2.pl (Postfix) with SMTP
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2009 23:00:20 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040407020504020509070805
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit

Hi *

I'm looking solution for following problem:

I have file server sharing files to diskless clients via NFS.

My /etc/export looks following:

[CODE]myth                 
192.168.1.0/24(rw,crossmnt,no_subtree_check,no_root_squash)
/tftpboot/PXEclient   
192.168.1.0/24(rw,no_subtree_check,no_root_squash)[/CODE]
 

I want  have setup, where plugging ext. USB HDD will be dynamically 
visible on clients as new <subdir> with plugged HDD contents.
So if user plug USB HD on server, diskless clients should see plugged 
HDD contents in dynamically created <subdirectory> with name equal to HD 
label and HD contents inside it.

I already wrote udev script which auto creates subdir=<label> in NFS 
server shared dir, and automounts USB HD in this subdir.
Udev script calls exportfs -r on add/remove operations.

My issue is that sometimes, after longer period of time (hours), in 
diskless clients, access to dir having HSB HD <subdir> causes stall.
In such case, cat /proc/fs/nfs/exports on NFS server gives:   

[CODE][root@mythtv ~]# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/tftpboot/PXEclient     
192.168.1.0/24(rw,no_root_squash,sync,wdelay,no_subtree_check,uuid=61c03e7b:9b7b4650:98dd78b4:18dc5ea6)
/       
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=82aa90c3:2cb44663:b912a340:38f73b56)
/myth/video/DVD_Rip     
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=cc740348:740334ac:00000000:00000000)
/myth   
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=fd3104ea:d5c04a8f:beba8ab6:9115b192)
/myth/video/HD  
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=c8c0a856:b8a54c08:9e4a4d48:58a37778)[/CODE]

In above listing, DVD_Rip is <subdir> created by udev script. In this 
<subdir> udev script mounts USB HDD.
I don't have clue why NFS server shares "/". Also I'm afraid about 
security, as for me it looks like server is sharing root dir...

Access to dir in diskless client become non-stalled when I remove USB HD 
(and udev scrip issue exportfs -r).
After such operation  /proc/fs/nfs/exports looks following:

[CODE][root@mythtv ~]# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/tftpboot/PXEclient     
192.168.1.0/24(rw,no_root_squash,sync,wdelay,no_subtree_check,uuid=61c03e7b:9b7b4650:98dd78b4:18dc5ea6)
/       
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=82aa90c3:2cb44663:b912a340:38f73b56)
/       
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=cc740348:740334ac:00000000:00000000)
/myth   
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=fd3104ea:d5c04a8f:beba8ab6:9115b192)
/myth/video/HD  
192.168.1.0/24(rw,no_root_squash,sync,wdelay,crossmnt,no_subtree_check,uuid=c8c0a856:b8a54c08:9e4a4d48:58a37778)
[root@mythtv ~]#[/CODE]

Here we have 2 "/" shares.
Whats going on here ?
Has somebody idea how I can resolve stall issue ?


Thx in advance

--------------040407020504020509070805
Content-Type: text/x-vcard; charset=utf-8;
 name="warpme.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="warpme.vcf"

begin:vcard
fn:Warpme
n:;Warpme
email;internet:warpme-h7QdYz1kt/Q@public.gmane.org
version:2.1
end:vcard


--------------040407020504020509070805--
