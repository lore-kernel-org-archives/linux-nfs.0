From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: Re: [NFS] locking failure with rpcbind and nfsroot (SLES 11, 2.6.27)
Date: Tue, 28 Jul 2009 12:31:50 +0200
Message-ID: <4A6ED396.7000705@bio.ifi.lmu.de>
References: <4A671ADE.5060109@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40320 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848AbZG1Kce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2009 06:32:34 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MVjyb-0006iC-6A
	for linux-nfs@vger.kernel.org; Tue, 28 Jul 2009 20:32:09 +1000
In-Reply-To: <4A671ADE.5060109-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So, is no one but me using root-over-nfs anymore?

Otherwise I wonder how one can handle a /var filesystem with root-over-nfs
and locking. I can't be the only one having this problem?!

cu,
FRank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

