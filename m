From: "saeed bishara" <saeed.bishara@gmail.com>
Subject: Re: read-ahead in NFS server
Date: Thu, 27 Dec 2007 10:50:04 +0200
Message-ID: <c70ff3ad0712270050u134616d1q459ed073c586dcec@mail.gmail.com>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com>
	 <47730F2F.3080900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"NFS list" <linux-nfs@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:63362 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbXL0IuI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2007 03:50:08 -0500
Received: by wa-out-1112.google.com with SMTP id v27so4721805wah.23
        for <linux-nfs@vger.kernel.org>; Thu, 27 Dec 2007 00:50:04 -0800 (PST)
In-Reply-To: <47730F2F.3080900@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> (linux-nfs added to cc)
>
> I cannot speak for the NFS server code specifically, but 32kb sounds
> like a network read (or write) data size limit.
yes
>
> Are you using TCP?  Are you using NFSv4, or an older version?
I'm using NFSv3/UDP.
I found that the actual requests size was 16KB, after doing some hacks
in server&client I managed to make it 60KB, now I see better
performance, and I see that the average request size is ~130KB which
means that there is actually read-ahead. but why it's only 130KB? how
can I make it larger?
when I run local dd with bs=4K, I can see that the average IO size is
more than 300KB.
