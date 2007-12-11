From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: Re: Client performance questions
Date: Tue, 11 Dec 2007 10:37:07 -0500
Message-ID: <e7ca40f70712110737x698b35a8g32377485cc7d8a16@mail.gmail.com>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:47748 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbXLKPhL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 10:37:11 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1188910nze
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2007 07:37:09 -0800 (PST)
In-Reply-To: <0a15723c4b267d4eb8b5ad05800315c0-FpffG6+3qsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings - we also run mail on NFS.

On Dec 10, 2007 4:52 PM, Fredrik Lindgren <fli-FpffG6+3qsA@public.gmane.org> wrote:

> Mount options on the clients are as follows:
> bg,intr,timeo=600,retrans=2,vers=3,proto=tcp,rsize=32768,wsize=32768
>
> MTU is 9000 bytes and they're all in the same Gigabit Ethernet switch along
> with the NFS server.
>
> Each client seems to be doing somewhere around 3500 NFS ops/s during peak hours.
> Average read/write size seems to be around 16kb, although these operations make
> up just ~30% of the activity.

This suggestion may get some controversy here - however it is what we
have done and its made a difference.

Try switching to UDP.  We've found that with mail applications, a
large amount of the transactions are small, and the windowing of TCP
actually slows things down.  This is what we use for mount options:

rw,v3,rsize=8192,wsize=8192,acregmin=15,acregmax=120,acdirmin=45,acdirmax=120,hard,lock,proto=udp

With a 9000 byte jumbo frame, this will restrict every datagram into a
single frame - also, you may want to play with sysctl
sunrpc.udp_slot_table_entries.  We keep this at 32., but it can go
right up to 128.

In our case, our issues with this config are nearly exclusively in
keeping our server side storage fast and responsive.

-Aaron
