Return-Path: linux-nfs-owner@vger.kernel.org
Received: from inspiron.ap.columbia.edu ([128.59.145.39]:48136 "EHLO
	inspiron.ap.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab2CLQ27 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 12:28:59 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
To: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
References: <878vj7x6mj.fsf@vostro.rath.org>
Date: Mon, 12 Mar 2012 12:20:17 -0400
In-Reply-To: <878vj7x6mj.fsf@vostro.rath.org> (Nikolaus Rath's message of
	"Sat, 10 Mar 2012 20:34:44 -0500")
Message-ID: <87pqchn64e.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nikolaus Rath <Nikolaus-BTH8mxji4b0@public.gmane.org> writes:
> The problem is that as soon as more than three clients are accessing the
> NFS shares, any operations on the NFS mountpoints by the clients hang.
> At the same time, CPU usage of the VPN processes becomes very high. If I
> run the VPN in debug mode, all I can see is that it is busy forwarding
> lots of packets. I also ran a packet sniffer which showed me that 90% of
> the packets were NFS related, but I am not familiar enough with NFS to
> be able to tell anything from the packets themselves. I can provide an
> example of the dump if that helps.

I have put a screenshot of the dump on
http://www.rath.org/res/wireshark.png (the full dump is 18 MB, and I'm
not sure which parts are important).

Any suggestions how I could further debug this?

Best,

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
