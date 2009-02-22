From: Rieker Flaik <rieker_flaik@arcor.de>
Subject: [NFS] NFS-HOWTO issue
Date: Sun, 22 Feb 2009 23:27:56 +0100
Message-ID: <1235341676.4039.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47746 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbZBVWzx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2009 17:55:53 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LbNEh-0002KA-4m
	for linux-nfs@vger.kernel.org; Mon, 23 Feb 2009 09:55:47 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

in the docu at http://nfs.sourceforge.net/nfs-howto/ar01s07.html section
Troubleshooting 7.2 (File requests hang or timeout waiting for access to
the file) it says:

 "This usually means that the client is unable to communicate with the
server. See Symptom 3 letter b."

But I can't find "Symptom 3 letter b" in the Documentation. Where is it?
I grepped through the whole Docs but only on page 7. and 5. is the word
"symptom" used.


And by the way, I cannot umount a still mounted nfs-volume when the
connection to the server is lost. But I want to do that. 



------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

