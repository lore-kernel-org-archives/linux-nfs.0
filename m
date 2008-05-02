From: Sten Spans <sten-4ZM2p5qjiQFChlZ7zSldDQ@public.gmane.org>
Subject: [NFS] bug in nfs-utils support/misc/tcpwrapper.c
Date: Sat, 3 May 2008 01:49:20 +0200 (CEST)
Message-ID: <alpine.DEB.0.99999.0805030130590.9075@zaphod.blinkenlights.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [220.233.11.133] ([220.233.11.133]:57853 "EHLO neil.brown.name"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759302AbYEBXub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 19:50:31 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Js50a-0003md-NL
	for linux-nfs@vger.kernel.org; Sat, 03 May 2008 09:49:44 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've been trying to get /etc/netgroup support going on
a machine serving nfs mounts to hosts located in various
.nl netblocks. Managing hosts this way greatly simplifies
hosts.allow and exports management, easily worth any slowdowns
during mounting.

I did notice a small problem in the tcpwrapper support:
(resulting in errors from mountd)

127    /* Check the official name first. */
128    if (hosts_ctl(daemon, "", hp->h_name, ""))
129         return 1;

this supplies the resolved hostname in the address field of hosts_ctl
which doesn't work. Changing it to:

if (hosts_ctl(daemon, hp->h_name, "", ""))

does work as expected. The h_aliases check on line 133 probably needs
the same change to work as expected.

-- 
Sten Spans

"There is a crack in everything, that's how the light gets in."
Leonard Cohen - Anthem

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

