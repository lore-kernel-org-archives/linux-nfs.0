From: Chuck Lever <chuck.lever@oracle.com>
Subject: RFC: Is SM_SIMU_CRASH (in rpc.statd) needed?
Date: Tue, 22 Jun 2010 10:34:58 -0400
Message-ID: <4C20CA12.2070002@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: Steve Dickson <SteveD@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:48908 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab0FVOfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jun 2010 10:35:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Does anybody know who uses SM_SIMU_CRASH and is it
> still needed? I'm getting some push back from our
> security folks to plug this DoS hole up...

How is it a DoS?  statd ignores any SM_SIMU_CRASH from a non-loopback 
address that does not use a privileged port.  To invoke it, you 
basically have to be a privileged local user.

Right now, no one uses it, but I think we should reserve the right to 
use it in the future.  This could be part of a more robust interface 
between lockd and statd.

-- 
Chuck Lever
