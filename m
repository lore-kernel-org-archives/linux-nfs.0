Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3067 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828Ab3KGVjp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 16:39:45 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Date: Thu, 7 Nov 2013 21:39:43 +0000
Message-ID: <1383860381.12966.37.camel@leira.trondhjem.org>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
	 <1383852380.12966.5.camel@leira.trondhjem.org>
	 <527C0548.1090205@RedHat.com>
In-Reply-To: <527C0548.1090205@RedHat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-11-07 at 16:25 -0500, Steve Dickson wrote:
+AD4- Hey,
+AD4- 
+AD4- On 07/11/13 14:26, Myklebust, Trond wrote:
+AD4- +AD4- On Thu, 2013-11-07 at 14:09 -0500, Steve Dickson wrote:
+AD4- +AD4APg- This new module parameter makes the v4 client
+AD4- +AD4APg- use the minimal authentication flavor (AUTH+AF8-UNIX)
+AD4- +AD4APg- when establishing NFSV4 state and doing the
+AD4- +AD4APg- pseudoroot lookup
+AD4- +AD4APg-
+AD4- +AD4- 
+AD4- +AD4- That looks very ad-hoc. Quite frankly, you can do the exact same thing
+AD4- +AD4- already by simply blacklisting the rpcsec+AF8-gss+AF8-krb5 and/or auth+AF8-rpcgss
+AD4- +AD4- modules.
+AD4- I tried to keep a very small foot print... I'm not sure why that 
+AD4- looks ad-hoc to you... 
+AD4- 
+AD4- If we blacklist those module(s) then we are disabling secure mounts
+AD4- altogether... 

What's the difference? If you use secure mounts, you really do want the
NFSv4 state to be secure too.

+AD4- +AD4- I think we should rather looks at adding a new mount option for
+AD4- +AD4- specifying the security flavour to use when establishing basic NFSv4.x
+AD4- +AD4- state, and then perhaps specifying the +AF8-default+AF8- for that mount option
+AD4- +AD4- using a module parameter.
+AD4- The problem is everything is hard code in these two areas so having
+AD4- a mount option would not work... 

We can change that code.

+AD4- The fact that -o sec+AD0-sys does not turn off the use of AUTH+AF8-GSS+AF8-KRB5x 
+AD4- is simple wrong... IMHO...

I beg to differ. The problem previously was that it +AF8-did+AF8- set the policy
for the state management, and that meant that if you has 2 mounts on the
same server with different security flavours, then then client behaviour
depended on the order of the mounts. Get the order wrong, and you get
anything from outright errors (CLID+AF8-IN+AF8-USE) to insecure behaviour.

+AD4-  Not having way to override this behavior
+AD4- is not a good thing... again... IMHO... 
+AD4- 
+AD4- Finally, Are there any servers out there today that support this type
+AD4- of behavior? Requiring secure state establishment or secure 
+AD4- pseudoroot lookups. 
+AD4- 
+AD4- Bruce, can we configure the Linux server to require this type security behavior? 
+AD4- Can any server out there require these type of security behavior?  
+AD4- 
+AD4- If the answer is no, then we really need a way to disable this type
+AD4- of behavior....

I don't disagree with the goal, I disagree with the method.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
