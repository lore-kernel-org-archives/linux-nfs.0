Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.iitb.ac.in ([59.162.23.13]:54332 "HELO smtp1.iitb.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754366Ab1EKT03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2011 15:26:29 -0400
Received: from nsl-23.cse.iitb.ac.in (nsl-23.cse.iitb.ac.in [10.105.12.23])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-auth.iitb.ac.in (Postfix) with ESMTP id 459DE13900
	for <linux-nfs@vger.kernel.org>; Wed, 11 May 2011 11:29:43 +0530 (IST)
Date: Wed, 11 May 2011 11:29:39 +0530 (IST)
From: Prateek Sharma <prateeks@cse.iitb.ac.in>
To: linux-nfs@vger.kernel.org
Subject: NFS latency tuning
Message-ID: <alpine.DEB.2.00.1105111123570.32365@nsl-23>
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello all,
 	I was wondering whether the NFS client implementation has any support 
for latency-based tcp-like 'windows'.
Basically my problem is: due to high request rate the server is swamped and 
response time is unbearable. If clients can be delayed from sending requests 
by introducing a 'waiting period' before every read/write request that might 
make things better.
 	Does NFS currently have such an implementation? (I could not find it in 
a quick scan of the code.) Is there even a need for what i have described above 
- are there other mechanisms present which allow for flow-control .

Thanks!
--
Prateek

