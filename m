From: Jari Aalto <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org>
Subject: Linux NFS-HOWTO - improvement to Troubleshooting permission denied
Date: Mon, 25 Aug 2008 10:36:00 +0300
Message-ID: <87skstbl7j.fsf@jondo.cante.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org (http://linux-nfs.org),
	chip@users.sourceforge.net, hjl@users.sourceforge.net,
	jbfields@users.sourceforge.net, jweber@users.sourceforge.net,
	marcmerlin@users.sourceforge.net, neilbrown@users.sourceforge.net,
	steved12345@users.sourceforge.net, trondmy@users.sourceforge.net
To: smithere@gmail.com (NFS HOWTO author)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:41852 "EHLO
	emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbYHYHp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 03:45:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Thank you for the NFS howto (last modified 2006). Please add further
diagnostics to section:

	=> "I do not have permission to access files on the mounted volume"
	http://nfs.sourceforge.net/nfs-howto/ar01s07.html#pemission_issues

The error condition "Permission denied" also happens in certain NFS
(client/server) combinations and the workaround is to add additional
mount parameter at client:

        sec=sys

Please add this to the "#pemission_issues" (tag the word seems to have a
small typo).

See reported incidents:

        http://thread.gmane.org/gmane.linux.debian.user/333162
        http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=492970

Jari

----
CC: team http://sourceforge.net/projects/nfs

You're all in CC, as I did not know who is responsible for updating the
NFS-HOWTO at sourceforge.
