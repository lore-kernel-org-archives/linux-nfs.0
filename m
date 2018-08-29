Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:5266 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727190AbeH2NMJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Aug 2018 09:12:09 -0400
Received: from srvvm01.ac.aixigo.de (mail.ac.aixigo.de [172.19.96.11])
        by gate5a.ac.aixigo.de (OpenSMTPD) with ESMTPS id 422d358c (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <linux-nfs@vger.kernel.org>;
        Wed, 29 Aug 2018 11:09:31 +0200 (CEST)
To: linux-nfs@vger.kernel.org
From: Harald Dunkel <harald.dunkel@aixigo.de>
Subject: nfs4_reclaim_open_state: Lock reclaim failed!
Message-ID: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
Date: Wed, 29 Aug 2018 11:09:31 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

dmesg -T shows me a large list of messages

:
[Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[Wed Aug 29 11:13:04 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
[Wed Aug 29 11:13:05 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
:

with a modification date appr 9 minutes in the future. NFS server and
client have the correct time and are in sync, afaict. How comes?


Kernel is 4.9.88-1+deb9u1 on the client, 4.16.5-1~bpo9+1 on the NFS server.


Every helpful comment is highly appreciated.
Harri
