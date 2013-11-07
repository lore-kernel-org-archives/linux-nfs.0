Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:26016 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab3KGW3z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 17:29:55 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Date: Thu, 7 Nov 2013 22:29:54 +0000
Message-ID: <1383863394.12966.63.camel@leira.trondhjem.org>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
		 <1383852380.12966.5.camel@leira.trondhjem.org>
		 <527C0548.1090205@RedHat.com>
	 <1383860381.12966.37.camel@leira.trondhjem.org>
	 <527C0CB6.8090308@RedHat.com>
In-Reply-To: <527C0CB6.8090308@RedHat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-11-07 at 16:57 -0500, Steve Dickson wrote:
+AD4- 
+AD4- On 07/11/13 16:39, Myklebust, Trond wrote:
+AD4- +AD4APg- If we blacklist those module(s) then we are disabling secure mounts
+AD4- +AD4APg- +AD4- altogether... 
+AD4- +AD4- What's the difference? If you use secure mounts, you really do want the
+AD4- +AD4- NFSv4 state to be secure too.
+AD4- Maybe I'm missing something via my testing.. It seems only the establishment
+AD4- of the state is insecure not the actual transactions using that state.
+AD4- So there is a window... but... 
+AD4- 
+AD4- Again, what servers, today, support this type of secure state establishment?
+AD4- Having this type of security in the client I think is good... but if
+AD4- the client is not talking with any servers that support this type 
+AD4- of security, why not have a way to turn it off?

I don't understand. Servers are +AF8-required+AF8- to support RPCSEC+AF8-GSS with
krb5 by both RFC3530 and RFC5661. AUTH+AF8-SYS is, in fact, the optional
flavour.

The problem here is that sometimes kerberos isn't configured by the
admin, who then expects that it shouldn't be necessary to run rpc.gssd
or rpc.svcgssd. It is necessary because we first try the
mandatory-to-implement and secure RPCSEC+AF8-GSS/krb5i flavour before
falling back to the less secure AUTH+AF8-SYS...

+AD4- +AD4APgA+- +AD4- +AD4- I think we should rather looks at adding a new mount option for
+AD4- +AD4APgA+- +AD4- +AD4- specifying the security flavour to use when establishing basic NFSv4.x
+AD4- +AD4APgA+- +AD4- +AD4- state, and then perhaps specifying the +AF8-default+AF8- for that mount option
+AD4- +AD4APgA+- +AD4- +AD4- using a module parameter.
+AD4- +AD4APg- +AD4- The problem is everything is hard code in these two areas so having
+AD4- +AD4APg- +AD4- a mount option would not work... 
+AD4- +AD4- We can change that code.
+AD4- +AD4- 
+AD4- +AD4APg- +AD4- The fact that -o sec+AD0-sys does not turn off the use of AUTH+AF8-GSS+AF8-KRB5x 
+AD4- +AD4APg- +AD4- is simple wrong... IMHO...
+AD4- +AD4- I beg to differ. The problem previously was that it +AF8-did+AF8- set the policy
+AD4- +AD4- for the state management, and that meant that if you has 2 mounts on the
+AD4- +AD4- same server with different security flavours, then then client behaviour
+AD4- +AD4- depended on the order of the mounts. Get the order wrong, and you get
+AD4- +AD4- anything from outright errors (CLID+AF8-IN+AF8-USE) to insecure behaviour.
+AD4- I see your point... but requiring all mounts to use some form 
+AD4- of security I don't think is the answer either... 

I'm saying that we may need a way to specify the security flavour to be
used by the client's state manager when establishing the NFSv4 lease,
and that would need to be done on a per-server basis.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
