Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:42569 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727245AbeH2NPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Aug 2018 09:15:39 -0400
Received: from srvvm01.ac.aixigo.de (mail.ac.aixigo.de [172.19.96.11])
        by gate5a.ac.aixigo.de (OpenSMTPD) with ESMTPS id f88f5841 (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO)
        for <linux-nfs@vger.kernel.org>;
        Wed, 29 Aug 2018 11:13:01 +0200 (CEST)
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
From: Harald Dunkel <harald.dunkel@aixigo.de>
To: linux-nfs@vger.kernel.org
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
Message-ID: <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
Date: Wed, 29 Aug 2018 11:13:01 +0200
MIME-Version: 1.0
In-Reply-To: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PS:

On 8/29/18 11:09 AM, Harald Dunkel wrote:
> Hi folks,
> 
> dmesg -T shows me a large list of messages
> 
> :
> [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:04 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> [Wed Aug 29 11:13:05 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> :
> 
> with a modification date appr 9 minutes in the future. NFS server and

Its a "timestamp", of course. Sorry.

> client have the correct time and are in sync, afaict. How comes?
> 
> 
> Kernel is 4.9.88-1+deb9u1 on the client, 4.16.5-1~bpo9+1 on the NFS server.
> 
> 
> Every helpful comment is highly appreciated.
> Harri
> 
