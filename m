From: Richard Scobie <richard-AknWbFEJEwOlP80pJB477g@public.gmane.org>
Subject: NFS breaking under heavy load intermittently
Date: Mon, 02 Nov 2009 17:00:30 +1300
Message-ID: <4AEE595E.8090203@sauce.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: Linux RAID Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.sauce.co.nz ([210.48.49.72]:46162 "EHLO smtp.sauce.co.nz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753759AbZKBEUL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Nov 2009 23:20:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Client: Core i7, 12GB Fedora 8  2.6.26.8-57.fc8 x86_64, NFS mount 
options rsize=32768,wsize=32768,intr,hard,vers=3, Gigabit connected.

Server: Core 2 Quad Xeon, 16GB Fedora 9 2.6.27.19-78.2.30.fc9.x86_64

Under some heavy work loads where the client is pulling large files and 
all CPUs are maxed out, the NFS connection "disappears" - df shows no 
entry for the NFS mount and some minutes later it will reappear again.

I am inclined to suspect the client, as similar workloads from other 
machines to the same server have no problem.

Suspecting the onboard Realtek NIC, I replaced it with an Intel, but the 
problem still occurs.

Can anyone tell me if there is likely to be a bug in these kernel 
versions that is contributing to this?

Any debugging advice would be gratefully received; other than this in dmesg:

nfs: server flash not responding, still trying
nfs: server flash not responding, still trying
nfs: server flash OK
nfs: server flash OK


there is nothing in the kerenl logs.

Regards,

Richard
