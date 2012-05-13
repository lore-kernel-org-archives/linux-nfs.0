Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48786 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab2EMMWy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 May 2012 08:22:54 -0400
Received: by bkcji2 with SMTP id ji2so3159821bkc.19
        for <linux-nfs@vger.kernel.org>; Sun, 13 May 2012 05:22:53 -0700 (PDT)
Message-ID: <4FAFA79A.2030007@tonian.com>
Date: Sun, 13 May 2012 15:22:50 +0300
From: Lior <lior@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>, Benny Halevy <bhalevy@tonian.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: nfs 4.1 server returns available file lyaout type when the file system
 is exported without pNFS
Content-Type: text/plain; charset=windows-1255; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Steps to reproduce:

insert this in /etc/export on the server side:
/mnt/testnfs 
*(rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534)

on the server side:
exportfs -ra

from client run connectathon:

The settings for connectathon are for nfs 4.1 without Pnfs ( although 
the module of: nfs_layout_nfsv41_files is loaded on the client due to 
the fact that the current clients design does not have an option of a 
module of nfs 4.1 WITHOUT pNFS)

Connectathon tests passed , but when I looked at nfsstat, I saw this ( 
relevant to Pnfs):
layoutget activity
layout return activity
(NO getdevice info activity)

(When I tried running the same , this time the server had this line in 
its /etc/exports:
/mnt/testnfs 
*(rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,fsid=0,anonuid=65534,anongid=65534,pnfs)
(NOTE: with Pnfs flag.)

connectathon tests passed , and when I looked at nfsstat, I saw this ( 
relevant to Pnfs):
layoutget activity
layoutreturn activity
getdevice info activity.)


  When we look at the logs and code, we saw that layoutget and layout 
return are sent by the client, and the server returns error messages to 
both ( as expected in regard to layoutget & layout return being sent by 
the client when the server is not pNFS enabled , BUT then again , the 
client wouldn't have sent layoutget & layout return ,originally, if it 
were to get the correct flag from the server, see Actuall behavior 
analysis below). we could also see that  there was NO getdevice info 
activity after that, and the server/client went on with regular nfs 
activity.

the no getdevice info activity was confirmed by the connectathon runs ( 
could be seen above).
expected results are:

     NO pNFS commands shown in nfsstat.
     NO pNFS module should be loaded in the client.

Actual behavior analysis
The FATTR4_FS_LAYOUT_TYPE field returned from the server, which should 
be empty, contains LAYOUT4_NFSV4_1_FILES, which causes the module to be 
loaded and the client to think pNFS is available.

Diagnosis:
This server behaviour is currently hard coded regardless of if we export 
a file system over pnfs or not. which doesn't seem right.

