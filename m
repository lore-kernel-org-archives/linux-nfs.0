Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from jay.phy.QueensU.CA ([130.15.24.47]:57005 "EHLO
	jay.phy.QueensU.CA" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab0H0Shr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 14:37:47 -0400
Received: from jay.phy.QueensU.CA (localhost.localdomain [127.0.0.1])
	by jay.phy.QueensU.CA (8.13.8/8.13.8) with ESMTP id o7RHmNOt029959
	for <linux-nfs@vger.kernel.org>; Fri, 27 Aug 2010 13:48:28 -0400
Received: (from peter@localhost)
	by jay.phy.QueensU.CA (8.13.8/8.13.8/Submit) id o7RHmNJG029958
	for linux-nfs@vger.kernel.org; Fri, 27 Aug 2010 13:48:23 -0400
Date: Fri, 27 Aug 2010 13:48:23 -0400
From: Peter Skensved <peter@jay.phy.QueensU.CA>
To: linux-nfs@vger.kernel.org
Subject: nfsd4_stateowners problem
Message-ID: <20100827174823.GA26792@jay.phy.QueensU.CA>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


  I'm looking for pointers and information on how to debug and annoying NFS
problem that has been bugging us for a long time. The problem is that the number
of nfsd4_stateowners keeps increasing until all low memory is exhausted and
the oom-killer is invoked. The severity of the problem has changed over time
with different kernels. At present it takes about 5 weeks for the size to
grow to 500 Mb  ( kernel 2.6.18-194.8.1.el5PAE, CentOS5.5 ). Restarting 
nfs clears up the problem but it is definitely not the preferred solution. 

 The increase in the number of nfsd4_stateowners appears to happen in bursts.
Nothing happens for long times and I suddenly see a burst. I've tried ( briefly )
to turn on all logging in rpcdebug and have run tcpdump while watching slabtop
but there is too much output to be able to see if there is anything strange
happening. So - my question is : how do I limit the diagnostic output to what
is relevant ? What are the modules and flags that I should be looking at ?
Any other info I should bemonitoring ? /proc/fs/nfsfs ?

                                                        peter
----

Peter Skensved                          Email : peter@SNO.Phy.QueensU.CA
Dept. of Physics,
Queen's University,
Kingston, Ontario,
Canada

