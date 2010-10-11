Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57104 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab0JKPRm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Oct 2010 11:17:42 -0400
Subject: Re: rpc sleep user task, will never wake up if response from server
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTimYM_A-puoU6tm=2rtAaKVe0_aW2zEwOCFHcu=y@mail.gmail.com>
Date: Mon, 11 Oct 2010 11:17:09 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <673201D6-5B4C-4782-ACB8-8C5B6E6B501E@oracle.com>
References: <AANLkTimYM_A-puoU6tm=2rtAaKVe0_aW2zEwOCFHcu=y@mail.gmail.com>
To: Ivan Chan <ivanming@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Take a look at http://nfs.sourceforge.net/

The upshot is that NFS defaults to "hard" mounts which means clients will retry an operation until it succeeds, possibly forever.  It sounds like you want a "soft" mount instead, which will time out operations that get no response.

Note that using "soft" may impact data integrity.

On Oct 11, 2010, at 4:46 AM, Ivan Chan wrote:

> Hi all,
> 
>    I am facing a problem in 2.6.32-31 kernel, when I try to fetch
> something from nfs server, and if there is no response server, for
> example loss IP.
> The user task will hang, and after scanning the RPC code, I think the
> user task is actualy being slept by RPC, and will not wake up until it
> get response from server.
> The following is the log, it show the RPC retry, and finally
> disconnect, However the use applcaiton is still hang/(sleep).  I am
> new to this, I don't know it is a design purpose for some condition or
> it should be fixed in generel. But in my use case, I hope the user
> application can know there is error from NFS/RPC, such that it can
> dicide to do the fail response. But I don't read the RPC code in deep
> yet,
> would you please suggest me which part I should focus , thanks a lot.
> 
> [363855.998281] NFS: permission(0:18/1443226), mask=0x1, res=0
> [363855.998286] NFS: dentry_delete(/out_A1.mp4, 88)
> [363855.998303] NFS: permission(0:18/1443226), mask=0x1, res=0
> [363855.998308] NFS: dentry_delete(/out_A3.mp4, 88)
> [363855.998325] NFS: permission(0:18/1443226), mask=0x1, res=0
> [363855.998329] NFS: dentry_delete(/zero, 88)
> [363895.460527] RPC:   172 reserved req c344a000 xid 5f9ff6fe
> [363895.460531] RPC:   172 xprt_prepare_transmit
> [363895.460536] RPC:   172 xprt_transmit(96)
> [363895.460556] RPC:   172 xmit complete
> [363955.460015] RPC:   172 xprt_timer
> [363955.460020] RPC:   172 xprt_prepare_transmit
> [363955.460025] RPC:   172 xprt_transmit(96)
> [363955.460037] RPC:   172 xmit complete
> [364075.460015] RPC:   172 xprt_timer
> [364075.460021] nfs: server 192.168.100.91 not responding, still trying
> [364075.460025] RPC:   172 xprt_prepare_transmit
> [364075.460030] RPC:   172 xprt_transmit(96)
> [364075.460042] RPC:   172 xmit complete
> [364135.460015] RPC:   172 xprt_timer
> [364135.460020] RPC:   172 xprt_prepare_transmit
> [364135.460026] RPC:   172 xprt_transmit(96)
> [364135.460038] RPC:   172 xmit complete
> [364255.460017] RPC:   172 xprt_timer
> [364255.460022] RPC:   172 xprt_prepare_transmit
> [364255.460027] RPC:   172 xprt_transmit(96)
> [364255.460039] RPC:   172 xmit complete
> [364315.460023] RPC:   172 xprt_timer
> [364315.460028] RPC:   172 xprt_prepare_transmit
> [364315.460033] RPC:   172 xprt_transmit(96)
> [364315.460045] RPC:   172 xmit complete
> [364435.460017] RPC:   172 xprt_timer
> [364435.460023] RPC:   172 xprt_prepare_transmit
> [364435.460028] RPC:   172 xprt_transmit(96)
> [364435.460041] RPC:   172 xmit complete
> [364495.460016] RPC:   172 xprt_timer
> [364495.460021] RPC:   172 xprt_prepare_transmit
> [364495.460026] RPC:   172 xprt_transmit(96)
> [364495.460038] RPC:   172 xmit complete
> [364615.460016] RPC:   172 xprt_timer
> [364615.460022] RPC:   172 xprt_prepare_transmit
> [364615.460027] RPC:   172 xprt_transmit(96)
> [364615.460039] RPC:   172 xmit complete
> [364675.460016] RPC:   172 xprt_timer
> [364675.460021] RPC:   172 xprt_prepare_transmit
> [364675.460026] RPC:   172 xprt_transmit(96)
> [364675.460039] RPC:   172 xmit complete
> [364795.460017] RPC:   172 xprt_timer
> [364795.460022] RPC:   172 xprt_prepare_transmit
> [364795.460027] RPC:   172 xprt_transmit(96)
> [364795.460040] RPC:   172 xmit complete
> [364855.460015] RPC:   172 xprt_timer
> [364855.460020] RPC:   172 xprt_prepare_transmit
> [364855.460025] RPC:   172 xprt_transmit(96)
> [364855.460037] RPC:   172 xmit complete
> [364944.152011] RPC:       disconnected transport c3682000
> [364944.152021] RPC:   172 xprt_prepare_transmit
> [364944.152026] RPC:   172 xprt_transmit(96)
> [364944.152031] RPC:       disconnected transport c3682000
> [364944.152037] RPC:   172 xprt_connect xprt c3682000 is not connected
> [364944.152052] RPC:       disconnected transport c3682000
> [364944.152058] RPC:   172 xprt_connect_status: retrying
> [364944.152061] RPC:   172 xprt_prepare_transmit
> [364944.152064] RPC:   172 xprt_transmit(96)
> [364944.152066] RPC:       disconnected transport c3682000
> [364944.152070] RPC:   172 xprt_connect xprt c3682000 is not connected
> 
> Regards,
> Ivan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




