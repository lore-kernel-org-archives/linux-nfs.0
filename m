Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magnum.mpi-bremen.de ([134.102.40.13]:54291 "HELO
	magnum.mpi-bremen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757715AbZABSTE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jan 2009 13:19:04 -0500
Message-ID: <495E5768.6050200@mpi-bremen.de>
Date: Fri, 02 Jan 2009 19:05:28 +0100
From: =?ISO-8859-1?Q?Elmar_Pr=FC=DFe?= <epruesse@mpi-bremen.de>
To: linux-nfs@vger.kernel.org
Subject: fairness of client?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi!

Is there a way to achieve fairness between users _on one client_?

While our users each had their own client, we never had a problem. But 
since we moved to a terminal server solution with many users sharing one 
machine, especially large writes cause a significant degradation of 
responsiveness for everyone else on the same client (ls can take > 1s).

Is this a configuration error? Or is the scenario too arcane to have 
been considered worthwhile optimizing?

We tried moving to NFS4, but that did not improve the situation.
Would it help to use an auto-mounter to give each user their own 
mount-point?
Or do we need to invest in 10GbE to shift the bottleneck back to the 
servers disks?
We run a 2.6.23.11 vanilla kernel. Would a newer version or applying the 
most recent NFS patches improve the situation?

I would really appreciate any hints as to which of the above is the most 
promising avenue. I tried finding information regarding this problem, 
but if there is any out there, it was shadowed by search results 
concerning a certain car racing game or tutorials for ancient kernel 
versions.

Elmar

ps: Happy New Year :)
