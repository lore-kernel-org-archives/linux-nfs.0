Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-5.MIT.EDU ([18.7.68.34]:62929 "EHLO
	dmz-mailsec-scanner-5.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754799Ab1G1TXJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 15:23:09 -0400
Received: from outgoing-legacy.mit.edu (OUTGOING-LEGACY.MIT.EDU [18.7.22.104])
	by mailhub-4.mit.edu (8.13.8/8.9.2) with ESMTP id p6SJN8VT003426
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2011 15:23:08 -0400
Received: from webmail-4.mit.edu (WEBMAIL-4.MIT.EDU [18.9.23.14])
	)
	by outgoing-legacy.mit.edu (8.13.6/8.12.4) with ESMTP id p6SJOspU019448
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2011 15:24:55 -0400 (EDT)
Received: (from nobody@localhost)
	by webmail-4.mit.edu (8.13.8/8.13.8/Submit) id p6SJN65Z010779
	for linux-nfs@vger.kernel.org; Thu, 28 Jul 2011 15:23:06 -0400
Message-ID: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
Date: Thu, 28 Jul 2011 15:23:06 -0400
From: Gregory Magoon <gmagoon@MIT.EDU>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 vs NFSv3 with MPICH2-1.4
Content-Type: text/plain;
	charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
I have been having issues when running MPICH2-1.4 on a NFSv4 filesystem (they
both seem to work fine on their own). When I mount as NFS version 4, I get lots
of NFS traffic on my internal network (seen when I run sudo iftop -i eth1) and
the mpich2 tests time out or give i/o errors. However, when I mount the NFS as
version 3, the MPICH2 tests seem to work without any major problems. Even
though I can get this working by switching to NFSv3, I would like to get MPICH2
working with NFSv4, if possible. Is there something in my NFS configuration (see
below) that is not possible with NFSv4 or is this some sort of conflict between
MPICH2-1.4 and NFSv4?

Thanks,
Greg


Here is the /etc/exports on the NFS server:
/usr/local 192.168.2.0/24(async,fsid=1,ro,no_root_squash,no_subtree_check)
/home 192.168.2.0/24(async,fsid=2,rw,no_root_squash,no_subtree_check)

Here are the NFS mounting details from "nfsstat -m":

NFSv4 (hangs and times out, with large quantity of NFS traffic):
 /home from 192.168.2.11:/home/
 Flags:
 rw,relatime,vers=4,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,port=0,timeo=20,retrans=32,sec=sys,clientaddr=192.168.2.1,minorversion=0,local_lock=none,addr=192.168.2.11

/usr/local from 192.168.2.11:/usr/local/
 Flags:
 ro,relatime,vers=4,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,port=0,timeo=20,retrans=32,sec=sys,clientaddr=192.168.2.1,minorversion=0,local_lock=none,addr=192.168.2.11

NFSv3 (works; mounted in fstab same as above except with nfs replacing nfs4 and
 nfsv and an extra option nfsvers=3):
 /home from 192.168.2.11:/home
 Flags:
 rw,relatime,vers=3,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=20,retrans=32,sec=sys,mountaddr=192.168.2.11,mountvers=3,mountport=55359,mountproto=udp,local_lock=none,addr=192.168.2.11

/usr/local from 192.168.2.11:/usr/local
 Flags:
 ro,relatime,vers=3,rsize=8192,wsize=8192,namlen=255,hard,proto=tcp,timeo=20,retrans=32,sec=sys,mountaddr=192.168.2.11,mountvers=3,mountport=55359,mountproto=udp,local_lock=none,addr=192.168.2.11


