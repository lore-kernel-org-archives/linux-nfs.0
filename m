From: Steve Gaarder <gaarder-O+4OpAMI7mIibAbXQ5Tkjg@public.gmane.org>
Subject: Can create and delete but not overwrite
Date: Tue, 17 Aug 2010 08:11:17 -0400 (EDT)
Message-ID: <alpine.LRH.2.00.1008170810510.2003@reuleaux2.math.cornell.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from math.cornell.edu ([128.84.234.110]:36520 "EHLO math.cornell.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754319Ab0HQNVy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 09:21:54 -0400
Received: from reuleaux2.math.cornell.edu ([128.84.234.141])
	by math.cornell.edu with esmtp (Exim 4.43)
	id 1OlL0f-000579-2t
	for linux-nfs@vger.kernel.org; Tue, 17 Aug 2010 08:11:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a strange problem with Kerberos security and NFVv4.

I have two servers, one running RHEL 4 (kernel 2.6.9-89.0.25.ELsmp) and the 
other RHEL 5 (2.6.18-194.3.1.el5).  Clients running either OS work fine.

I have one user who is using Ubuntu (9.04 Jaunty; the kernel is 
2.6.28-19-generic #61-Ubuntu).  On that machine, he can access filesystems on 
the RHEL 5 server fine. Using filesystems mounted from the RHEL 4 server, 
authenticated users can create and write files, but they cannot write to an 
existing file. SO, for example,

echo foo >foo

works, but a subsequent

echo foo >foo

says "Input/Output Error".

Any ideas?

-- 
Steve Gaarder
System Administrator, Dept of Mathematics
Cornell University, Ithaca, NY, USA
gaarder-O+4OpAMI7mIibAbXQ5Tkjg@public.gmane.org
