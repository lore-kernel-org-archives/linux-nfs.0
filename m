Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:41014 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933194AbaDBVQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2014 17:16:39 -0400
Received: from [107.17.32.114] ([107.17.32.114])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id s32LGWJk008942
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 2 Apr 2014 14:16:32 -0700
Message-ID: <533C7E2F.7060201@candelatech.com>
Date: Wed, 02 Apr 2014 14:16:31 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Quick way to check if file is on nfs?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there an efficient way to tell if a file we just opened is on
NFS vs local disk?  We have reports of a bug where our program thinks
it has mounted nfs and starts writing to the nfs file system, but later
somehow local disk gets filled up instead.  I'd like to detect when
we are no longer writing to the mount point so I can stop the test,
gather logs, etc.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

