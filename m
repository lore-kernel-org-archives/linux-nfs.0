Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57774 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726493AbeHaP5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Aug 2018 11:57:00 -0400
Message-ID: <30d4e07de5d976756857db77ddb17582897ae2bf.camel@kernel.org>
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
From: Jeff Layton <jlayton@kernel.org>
To: Harald Dunkel <harald.dunkel@aixigo.de>, linux-nfs@vger.kernel.org
Date: Fri, 31 Aug 2018 07:49:50 -0400
In-Reply-To: <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
         <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-08-29 at 11:13 +0200, Harald Dunkel wrote:
> PS:
> 
> On 8/29/18 11:09 AM, Harald Dunkel wrote:
> > Hi folks,
> > 
> > dmesg -T shows me a large list of messages
> > 
> > :
> > [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [Wed Aug 29 11:13:02 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [Wed Aug 29 11:13:03 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [Wed Aug 29 11:13:04 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > [Wed Aug 29 11:13:05 2018] NFS: nfs4_reclaim_open_state: Lock reclaim failed!
> > :
> > 
> > with a modification date appr 9 minutes in the future. NFS server and
> 
> Its a "timestamp", of course. Sorry.
> 
> > client have the correct time and are in sync, afaict. How comes?
> > 
> > 
> > Kernel is 4.9.88-1+deb9u1 on the client, 4.16.5-1~bpo9+1 on the NFS server.
> > 
> > 
> > Every helpful comment is highly appreciated.
> > Harri
> > 
> 
> 

Hi Harald,

Usually this means that the client and server have gotten out of sync
(possibly due to a server reboot), the client has tried to reclaim the
state it held before but that reclaim failed.

Determining why that happened is is difficult from the info you have
here. Is your server being restarted regularly? What version of NFS are
you using to mount?

v4.9 is pretty old at this point as well, you may want to try a newer
kernel on the client and see if it behaves better.
-- 
Jeff Layton <jlayton@kernel.org>
