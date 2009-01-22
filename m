From: Ben Greear <greearb@candelatech.com>
Subject: Re: Possible bug in nfs-utils source.
Date: Wed, 21 Jan 2009 16:00:27 -0800
Message-ID: <4977B71B.4030003@candelatech.com>
References: <4977A0EC.3050103@candelatech.com> <2055BE67-5060-4D4E-BB0A-A8E61152A2EC@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080008050503090608030608"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51077 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbZAVAAe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 19:00:34 -0500
In-Reply-To: <2055BE67-5060-4D4E-BB0A-A8E61152A2EC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080008050503090608030608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Chuck Lever wrote:
> On Jan 21, 2009, at Jan 21, 2009, 5:25 PM, Ben Greear wrote:
>> I'm working on adding support to bind to local addresses, and
>> I noticed this code in nfs/getport.c
>>
>> I believe the sizeof should probably be sizeof(*lb_addr) ?
> 
> Yes.  Can you submit a patch to Steve and copy the list?


The patch is attached.

Signed-Off-By:  Ben Greear <greearb@candelatech.com>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------080008050503090608030608
Content-Type: text/x-patch;
 name="nfs_sizeof.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs_sizeof.patch"

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 47824a2..f5f7049 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -836,7 +836,7 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 {
 	struct sockaddr_storage address;
 	struct sockaddr *lb_addr = (struct sockaddr *)&address;
-	socklen_t lb_len = sizeof(lb_addr);
+	socklen_t lb_len = sizeof(*lb_addr);
 	unsigned short port = 0;
 
 #ifdef NFS_GP_LOCAL

--------------080008050503090608030608--
