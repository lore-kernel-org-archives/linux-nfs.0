Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53067 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751878Ab0IGHsE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 03:48:04 -0400
Message-ID: <4C85EE24.9070007@cn.fujitsu.com>
Date: Tue, 07 Sep 2010 15:47:48 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Query regarding NFS packet capture at application layer - umount
 operation.
References: <D3F292ADF945FB49B35E96C94C2061B90D19835A@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90D19835A@nsmail.netscout.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Hi,
> 
> I have a query related to NFS packet captured at application layer. I
> have setup the NFS node on local system itself (just for test purpose). 
> And capturing the packets for various events (mount, umount, file access
> etc) on loop-back interface itself. However, in case of the umount
> scenario, I do not see any NFS packet captured (I can only see three TCP
> packets exchanged). 
> 
> Could someone please explain why there is no NFS packet observed during
> an unmount? Also there seems not much information, related to NFS mount
> point being unmounted, in TCP packet. So is there any way to detect the
> unmount operation by hacking such packets?
> 

  I guess you used NFSv4. NFSv4 umount operation does not send any NFS packet.
  The TCP packets you captured were sent by TCP close procedure, because NFS
  umount operation need close the TCP connection with NFS server.

-- 
Regards
Bian Naimeng

