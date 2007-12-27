From: "saeed bishara" <saeed.bishara@gmail.com>
Subject: Re: read-ahead in NFS server
Date: Thu, 27 Dec 2007 17:00:12 +0200
Message-ID: <c70ff3ad0712270700h6336b194r7c21834423aeb331@mail.gmail.com>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com>
	 <47730F2F.3080900@garzik.org>
	 <c70ff3ad0712270050u134616d1q459ed073c586dcec@mail.gmail.com>
	 <47739288.7000308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"NFS list" <linux-nfs@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:21419 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbXL0PAN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2007 10:00:13 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4903454wah.23
        for <linux-nfs@vger.kernel.org>; Thu, 27 Dec 2007 07:00:12 -0800 (PST)
In-Reply-To: <47739288.7000308@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >> Are you using TCP?  Are you using NFSv4, or an older version?
> > I'm using NFSv3/UDP.
>
> IMO, you definitely want TCP and NFSv4.  Much better network behavior,
> with some of the silly UDP limits (plus greatly improved caching
> behavior, due to v4 delegations).
the clients of my system going to be embedded system with low
performance cpus and I need UDP as it needs less cpu power.

> > when I run local dd with bs=4K, I can see that the average IO size is
> > more than 300KB.
>
> Read-ahead is easier in NFSv4, because the client probably has the file
> delegated locally, and has far less need to constantly revalidate file
> mapping(s).
I'll check that.
but what about the server side? why the issued IO's are only as twice
as the size of the NFS requests?
