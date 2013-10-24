Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:21112 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106Ab3JXPIV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 11:08:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 15:08:19 +0000
Message-ID: <1382627297.6430.0.camel@leira.trondhjem.org>
References: <658674512.46.1382627110304.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <658674512.46.1382627110304.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 11:05 -0400, Matt W. Benjamin wrote:
+AD4- Hi,
+AD4- 
+AD4- Presumably Linux client and server implementations would restrict use of +ACI-system.+ACI-
+AD4- Perhaps would be more to talk about, if xattrs were implemented experimentally.
+AD4- 
+AD4- I'm interested in knowing about patches that might be floating around for the Linux client, for NFSv4.x.  (I've seen NFSv3 work.)
+AD4- 
+AD4- Thanks,
+AD4- 
+AD4- Matt

We've already talked about this, Matt. The answer is still NO.

Trond

+AD4- ----- +ACI-Trond Myklebust+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- On Oct 24, 2013, at 3:13 PM, Christoph Anton Mitterer
+AD4- +AD4- +ADw-calestyo+AEA-scientia.net+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4- +AD4- On Thu, 2013-10-24 at 08:45 +-0000, Myklebust, Trond wrote:
+AD4- +AD4- +AD4APg- labeled NFS (i.e. security labels for NFS) is already supported in
+AD4- +AD4- Linux 3.10 and newer.
+AD4- +AD4- +AD4- Sure, but that doesn't really help me.
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4APg- There are no plans to merge general purpose xattrs.
+AD4- +AD4- +AD4- Why not? Is it a big deal?
+AD4- +AD4- +AD4- 
+AD4- +AD4- 
+AD4- +AD4- Linux xattrs are a rabid mess.
+AD4- +AD4- 
+AD4- +AD4- The whole +ACI-system+ACI- namespace is something that cannot and should not
+AD4- +AD4- ever be exposed on a network.
+AD4- +AD4- The +ACI-trusted+ACI- and +ACI-user+ACI- namespaces just offer specialised storage.
+AD4- +AD4- Why are they needed?
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4APg- Please just use an application-specific database.
+AD4- +AD4- +AD4- Well that won't work,... since that wouldn't be updated if e.g.
+AD4- +AD4- +AD4- pathnames are changed by any program (cp, mv)
+AD4- +AD4- 
+AD4- +AD4- If the data needs to follow the file, then store it in the file. Why
+AD4- +AD4- do you need the filesystem to manage that for you?
+AD4- +AD4- 
+AD4- +AD4- Cheers
+AD4- +AD4-   Trond--
+AD4- +AD4- To unsubscribe from this list: send the line +ACI-unsubscribe linux-nfs+ACI-
+AD4- +AD4- in
+AD4- +AD4- the body of a message to majordomo+AEA-vger.kernel.org
+AD4- +AD4- More majordomo info at  http://vger.kernel.org/majordomo-info.html
+AD4- 

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
