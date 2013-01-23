Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47890 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599Ab3AWNfN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 08:35:13 -0500
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <50FF8DEC.9070901@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com>  <50FF4BC9.1060206@candelatech.com>
	 <1358921493.12374.737.camel@edumazet-glaptop>
	 <50FF8DEC.9070901@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Jan 2013 05:35:10 -0800
Message-ID: <1358948110.12374.748.camel@edumazet-glaptop>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-01-22 at 23:14 -0800, Ben Greear wrote:

> How are the non-ref-counted dst objects used safely?  Any chance
> that tearing down the IP protocol on a device (or deleting a device)
> could delete a dst that is referenced by an skb (and thus crashes as
> I see)?

There is probably a bug. Normally it should be RCU protected.



