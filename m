From: "saeed bishara" <saeed.bishara@gmail.com>
Subject: Re: read-ahead in NFS server
Date: Thu, 27 Dec 2007 17:38:57 +0200
Message-ID: <c70ff3ad0712270738v2551224ft5694a5673c37aa3c@mail.gmail.com>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com>
	 <47730F2F.3080900@garzik.org>
	 <c70ff3ad0712270050u134616d1q459ed073c586dcec@mail.gmail.com>
	 <47739288.7000308@garzik.org>
	 <c70ff3ad0712270700h6336b194r7c21834423aeb331@mail.gmail.com>
	 <4773BFBA.70709@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"NFS list" <linux-nfs@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:56865 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbXL0Pi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2007 10:38:58 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4921525wah.23
        for <linux-nfs@vger.kernel.org>; Thu, 27 Dec 2007 07:38:57 -0800 (PST)
In-Reply-To: <4773BFBA.70709@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>
> I bet
>         TCP + fewer revalidations + greater local pagecache activity
> uses less cpu power than
>         UDP + revalidations + rx/tx network activity
what do you mean by revalidations?
the workload of the client going to be large sequential IO's, so does
the local pagecache is necessary for this case?

saeed
