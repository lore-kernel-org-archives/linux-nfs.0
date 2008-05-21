From: "Erik Hensema / HostingXS Internet Services" <hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Subject: Re: [NFS] nfs locking problems maybe solved
Date: Wed, 21 May 2008 15:27:09 +0200
Message-ID: <200805211527.10783.hensema@hostingxs.nl>
References: <200805211320.35610.hensema@hostingxs.nl>
	<RTPCLUEXC1-PRDqKwRP0000013f@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43949 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762063AbYEUN10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 09:27:26 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JyoLj-0007E5-KK
	for linux-nfs@vger.kernel.org; Wed, 21 May 2008 23:27:23 +1000
In-Reply-To: <RTPCLUEXC1-PRDqKwRP0000013f-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On woensdag 21 mei 2008, Talpey, Thomas wrote:
> At 07:20 AM 5/21/2008, Erik Hensema / HostingXS Internet Services 
wrote:
> >So I granted 192.168.200.45 access to the portmapper on voyager,
> > and most clients were unstuck. I updated hosts.allow on most
> > clients to grant access to the portmapper now.
> >
> >Now I still have about 4 clients which can't lock rrd files.
>
> ...
>
> >Everything is NFSv3 by the way. Most clients are opensuse 10.2
> > (kernel 2.6.18.8), server is opensuse 10.3 (kernel 2.6.22.17).
>
> You need to grant access to the client's portmap, nlm and statd
> ports in order for the server to call back with locking operations.
> Unfortunately, only portmap is at a well-known port (111). The nlm
> and statd ports are dynamically selected, and receive random high
> numbered port values.

That's no problem to me, I don't firewall ports on the internal 
network. I do have an "ALL : ALL" line in hosts.deny, so I 
explicitely have to open services using tcp_wrapper.


Met vriendelijke groet,


Erik Hensema
-- 
HostingXS
eXcellent Service

Telefoon: 024 - 324 91 77
E-mail:   hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org
Website:  http://www.hostingxs.nl/

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

