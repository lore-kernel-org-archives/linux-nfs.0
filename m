From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 0/3] nfsstat: Fixing and improving the new --sleep and --list
 options
Date: Wed, 08 Apr 2009 10:51:06 -0400
Message-ID: <49DCB9DA.5000300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51268 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932474AbZDHOxx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2009 10:53:53 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n38Erq7S007441
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 10:53:52 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n38ErsZI002060
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 10:53:54 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-147.bos.redhat.com [10.16.10.147])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n38ErqSo009863
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 10:53:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using the new --sleep and --list options to nfsstats,
I found a server side bug and an annoyance when particular
protocols where specified. 

When the --sleep options as used with a particular protocol
option (i.e. -2, -3 or -4) and there was no traffic, blank
lines were being echoed to the screen causing useful data
to be scrolled of the screen.

Also with the --sleep option, the server stats were not
being updated which meant the same values would be echoed
again and again when there was not new server traffic.

Finally when using the --sleep and/or --list options, zero 
stats will not be displayed. I found it much more useful to
show what happen instead of showing what did not happen. 
Plus not showing zero stats makes the --list much easier to 
read and digest as well as keeping useful data from scrolling
off the screen.

The server side bug was the fact --list didn't on server
stats. The client stats were being check when the server
stats should have been.

steved.
