From: Greg Banks <gnb@sgi.com>
Subject: [patch 0/5] activate & deactivate dprintks individually and severally
Date: Tue, 20 Jan 2009 12:29:30 +1100
Message-ID: <20090120012930.020621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>,
	Linux NFSv4 ML <nfsv4@linux-nfs.org>,
	SystemTAP ML <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:42110 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753976AbZATBdH (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 20:33:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As mentioned in the recent discussion on NFS trace points on the NFS &
SystemTap mailing lists.  This patch allows field support staff and
kernel developers debug kernel problems, by enabling them to treat
dprintks as precise trace points rather than syslog spamming tools.

This is a forward ported (from 2.6.16), updated, and split version
of a patch that has been used in SGI's internal development tree for
the last few months.  The very first version of this was used about
eighteen months ago when debugging NFS/RDMA, which has an enormous
number of dprintks and no other way to debug it.

Jason Baron suggested I post it here for review and contrast with
his dynamic dprintk feature.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
