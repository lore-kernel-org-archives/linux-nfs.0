Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55594 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934263Ab1KCSb4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 14:31:56 -0400
Message-ID: <4EB2DE17.7030005@panasas.com>
Date: Thu, 3 Nov 2011 11:31:51 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Regarding the Fedora 15 nfs-utils--pnfs RPM
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve

On your pnfs site here:
http://steved.fedorapeople.org/repos/pnfs/15/x86_64/rpms/

You have this RPM:
	nfs-utils-1.2.3-10.pnfs.fc15.x86_64.rpm

It was all well and on any live system we could just do:
	yum localinstall nfs-utils-1.2.3-10.pnfs.fc15.x86_64.rpm
	(Or even better put it on our Cobbler server)

But recently  Fedora 15 updated to:
	nfs-utils-1.2.4-1.fc15.x86_64.rpm

And the above localinstall no longer works (Version math)
The nfs-utils-1.2.4-1 needs to be removed and the nfs-utils-1.2.3-10.pnfs
installed, but on every update it wants to be replaced.

Could you please bump up the pnfs RPM version so it will be higher
then FC15's ?

On a side note. Can we put the pNFSD-server supporting bits in nfs-utils
even though the pNFSD-server is not yet in Kernel. Like parse the pnfs
option in /etc/exports but ignore if not supported by Kernel?
I mean what will we do in the future when a new nfs-utils boots with an old
Kernel? can we do the same now?

Thanks
Boaz
