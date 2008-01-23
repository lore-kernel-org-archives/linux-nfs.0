From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] nfs_statfs: statfs error = 512 ?
Date: Wed, 23 Jan 2008 15:37:38 -0500
Message-ID: <4797A592.4080903@RedHat.com>
References: <479763EC.3090601@bnl.gov> <4797699C.2020100@RedHat.com>
	<47976B05.60408@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43736 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbYAWUh5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2008 15:37:57 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JHmM6-000863-BQ
	for linux-nfs@vger.kernel.org; Thu, 24 Jan 2008 07:37:54 +1100
In-Reply-To: <47976B05.60408-IGkKxAqZmp0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sev Binello wrote:
> The problem doesn't seem to occur on WS3 clients,  but does on  WS4
> clients ?
Again, I'm pretty sure this problem was identified and fixed in
an later update release... you could try updating to the latest 
and greatest (U7).
 
> Can you provide any more details ?
An a bzip2 tethereal network trace something similar to
    tethereal -w /tmp/data.pcap host <server> and host <server;
    bzip2 /tmp/data.pcap

should shed some light on whats going on... 

Note: so as not to fill up everybody's inbox with tethereal
data, either open a bug report on bugzilla.redhat.com or
set the data to me in a private email.

steved.

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

