From: "howard chen" <howachen@gmail.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Fri, 26 Sep 2008 23:57:32 +0800
Message-ID: <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
	 <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com>
	 <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:43735 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbYIZP5e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 11:57:34 -0400
Received: by yw-out-2324.google.com with SMTP id 9so173719ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2008 08:57:32 -0700 (PDT)
In-Reply-To: <RTPCLUEXC2-PRDNXRPm0000003a-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Fri, Sep 26, 2008 at 11:25 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
> At 11:05 AM 9/26/2008, howard chen wrote:
> You didn't indicate what the client and server were, btw.

client is 3, as I see when mount with verbose option: ... mount:
trying xxxx prog 100003 vers 3 prot udp port 2049

server should be also 3, default by CentOS 4.4, 64bit

>
> Do you have multiple interfaces on the client? If the client routing
> originates from a different address than 10.10.10.2, then the server
> will deny it because you have specified a numerical address.

Yes, both servers have interface for public IP, but as I can see the
10.10.10.2 in /var/log/message of NFS server, so I think routing is
ok.



> This isn't the source of the permissions error, but why are you doing
> a UDP mount, and with only three retries? Generally, TCP will perform
> better, and more robustly. Also, the "noatime" option is a no-op for
> the NFS client (servers are in charge of maintaining atime).

I agree TCP is more robust, but isn't UDP will have a better performance?

Thanks.
