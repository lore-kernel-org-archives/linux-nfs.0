Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trumpkin.cc.andrews.edu ([143.207.1.81]:51452 "EHLO
	trumpkin.cc.andrews.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757330Ab2BHWgd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 17:36:33 -0500
Received: from secures.cc.andrews.edu (root@secures.cc.andrews.edu [143.207.1.47])
	by trumpkin.cc.andrews.edu (8.14.4/8.14.4/Debian-2) with ESMTP id q18MSbWM029481
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 8 Feb 2012 17:28:37 -0500
Received: from [143.207.4.197] (blackhole.cc.andrews.edu [143.207.4.197])
	(authenticated bits=0)
	by secures.cc.andrews.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id q18MSbeE021108
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 8 Feb 2012 17:28:37 -0500
Message-ID: <4F32F726.4060704@andrews.edu>
Date: Wed, 08 Feb 2012 17:28:54 -0500
From: Todd Freeman <freeman@andrews.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfsd4_stateowners eating memory like candy... sometimes....
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good day all!

I have a nfs server handling the load for a shared file system for 5 web 
servers...  some relevant info:
   libnfsidmap2                                                         
0.23-2
   nfs-common                                                           
1:1.2.2-1ubuntu1.1
   nfs-kernel-server                                                    
1:1.2.2-1ubuntu1.1

   Linux webnfs 2.6.35-31-server #63-Ubuntu SMP Mon Nov 28 21:03:37 UTC 
2011 x86_64 GNU/Linux

On this server everything runs great for a couple weeks to a month and 
then we start getting sluggish performance... and within a couple days 
it seizes up (at least all nfs services stop... console is still accessible)

In trying to debug this we have been taking a snap shot every 5 minutes 
of the slabinfo...   we got a totally clean capture this time and I see 
nfsd4_stateowners running away with memory. When we start the server and 
for the first several days the most memory it uses is 200MB or so...  
over time though there come points were it suddenly starts munching 
more...  sometimes slowly... other times instantly. It finally kills the 
machine when it reaches the 1.7-1.8 GB level (just under the memory size 
of the machine). oom-killer is killing everything left and right at the 
end and we end up with a machine that is comatose NFS wise till we do a 
full reboot.

You can see a graph of this usage pattern at: http://imgur.com/ecLPh

I see mentions of a problem along this line back in the 2.6.16-18 types 
days... but supposedly it was fixed.

Does anyone have any ideas?

-- 
Todd Freeman  Ext 6103                   .^.    Don't fear the penguins!
Programming Department                   /V\
Andrews University                      // \\    http://www.linux.org/
http://www.andrews.edu/~freeman/       /(   )\   http://www.debian.org/
                                         ^^ ^^

