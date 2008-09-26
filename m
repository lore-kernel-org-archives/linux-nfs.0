From: "howard chen" <howachen@gmail.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Fri, 26 Sep 2008 23:05:27 +0800
Message-ID: <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
	 <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:50401 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbYIZPF2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 11:05:28 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1145799wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2008 08:05:28 -0700 (PDT)
In-Reply-To: <RTPCLUEXC2-PRDM3SOl0000001f-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.


On Fri, Sep 26, 2008 at 7:50 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
> Just because it's "authenticated" doesn't mean you have "permission".
> What are the contents of your server's export file, and the umode of
> the target /data0/tmp directory? And btw, what types/versions are
> your client and server?
>

Thanks. Consider below as the full picture:

NFS Server (10.10.10.1)
=========================
/data0/tmp	10.10.10.2(rw,sync)

NFS Client (10.10.10.2)
=======================
# Add in /etc/rc.local
mount -t nfs -o
async,noatime,noexec,nosuid,hard,intr,udp,retry=3,rsize=32768,wsize=32768
10.10.10.1:/data0/tmp     /home/www/tmp

ls /data0/

drwxrwxr-x  261 root web  12288 Sep 26 22:58 tmp



Thanks.
