From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] nfs locking problems maybe solved
Date: Wed, 21 May 2008 10:02:57 -0400
Message-ID: <RTPCLUEXC1-PRD8gnsH00000142@RTPMVEXC1-PRD.hq.netapp.com>
References: <200805211320.35610.hensema@hostingxs.nl>
	<RTPCLUEXC1-PRDqKwRP0000013f@RTPMVEXC1-PRD.hq.netapp.com>
	<200805211527.10783.hensema@hostingxs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Erik Hensema / HostingXS Internet Services" <hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58994 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759424AbYEUOFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 10:05:13 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JyowI-0007KK-Se
	for linux-nfs@vger.kernel.org; Thu, 22 May 2008 00:05:10 +1000
In-Reply-To: <200805211527.10783.hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
References: <200805211320.35610.hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
	<RTPCLUEXC1-PRDqKwRP0000013f-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
	<200805211527.10783.hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 09:27 AM 5/21/2008, Erik Hensema / HostingXS Internet Services wrote:
>That's no problem to me, I don't firewall ports on the internal 
>network. I do have an "ALL : ALL" line in hosts.deny, so I 
>explicitely have to open services using tcp_wrapper.

Your followup reminds me that some kernels use local RPC to communicate
between nlm and statd on the client as well. So, if you haven't included
the local client host in your hosts.allow for at least these services, that
may be advisable.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

