From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Fri, 26 Sep 2008 11:25:49 -0400
Message-ID: <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
 <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
 <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com> <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "howard chen" <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58720 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbYIZP1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 11:27:08 -0400
In-Reply-To: <b66ddc900809260805g71578cacr73a526e87a77e677-JsoAwUIsXouhRSP0FMvGiw@public.gmane.org
 m>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <RTPCLUEXC2-PRDM3SOl0000001f-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <b66ddc900809260805g71578cacr73a526e87a77e677-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 11:05 AM 9/26/2008, howard chen wrote:
>Thanks.
>
>
>On Fri, Sep 26, 2008 at 7:50 PM, Talpey, Thomas
><Thomas.Talpey@netapp.com> wrote:
>> Just because it's "authenticated" doesn't mean you have "permission".
>> What are the contents of your server's export file, and the umode of
>> the target /data0/tmp directory? And btw, what types/versions are
>> your client and server?
>>
>
>Thanks. Consider below as the full picture:

You didn't indicate what the client and server were, btw.

Do you have multiple interfaces on the client? If the client routing
originates from a different address than 10.10.10.2, then the server
will deny it because you have specified a numerical address. You might
try exporting to "*" to see if this changes anything. Apart from that
possibility, the configuration looks plausible.

This isn't the source of the permissions error, but why are you doing
a UDP mount, and with only three retries? Generally, TCP will perform
better, and more robustly. Also, the "noatime" option is a no-op for
the NFS client (servers are in charge of maintaining atime).

Tom.

>
>NFS Server (10.10.10.1)
>=========================
>/data0/tmp	10.10.10.2(rw,sync)
>
>NFS Client (10.10.10.2)
>=======================
># Add in /etc/rc.local
>mount -t nfs -o
>async,noatime,noexec,nosuid,hard,intr,udp,retry=3,rsize=32768,wsize=32768
>10.10.10.1:/data0/tmp     /home/www/tmp
>
>ls /data0/
>
>drwxrwxr-x  261 root web  12288 Sep 26 22:58 tmp
>
>
>
>Thanks.

