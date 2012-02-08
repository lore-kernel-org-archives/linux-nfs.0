Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bear.ext.ti.com ([192.94.94.41]:53167 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757304Ab2BHCpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 21:45:33 -0500
Received: from dlep26.itg.ti.com ([157.170.170.121])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id q182jWCM002406
	for <linux-nfs@vger.kernel.org>; Tue, 7 Feb 2012 20:45:32 -0600
Received: from DLEE74.ent.ti.com (localhost [127.0.0.1])
	by dlep26.itg.ti.com (8.13.8/8.13.8) with ESMTP id q182jWok009621
	for <linux-nfs@vger.kernel.org>; Tue, 7 Feb 2012 20:45:32 -0600 (CST)
Received: from [172.24.113.225] (h113-225.vpn.ti.com [172.24.113.225])	by
 dlelxv22.itg.ti.com (8.13.8/8.13.8) with ESMTP id q182jVDT029209	for
 <linux-nfs@vger.kernel.org>; Tue, 7 Feb 2012 20:45:32 -0600
Message-ID: <4F31E1CA.8060105@ti.com>
Date: Tue, 7 Feb 2012 20:45:30 -0600
From: Derek McEachern <derekm@ti.com>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: NFS Mount Option 'nofsc'
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I joined the mailing list shortly after Neil sent out a request for 
volunteer to update the nfs man page documenting the 'fsc'/'nofsc' 
options. I suspect this may stem from a ticket we opened with Suse 
inquiring about these options.

Coming from a Solaris background we typically use the 'forcedirectio' 
option for certain mounts and I was looking for the same thing in Linux. 
The typically advice seems to be use 'noac' but the description in the 
man page doesn't seem to match what I would expect from 'forcedirectio', 
namely no buffering on the client.

Poking around the kernel I found the 'fsc'/'nofsc' options and my 
question is does 'nofsc' provide 'forcedirectio' functionality?

Thanks,
Derek



