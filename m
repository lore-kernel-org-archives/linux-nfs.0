Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:29743 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024Ab3KKVCV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 16:02:21 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS atime behavior is not documented
Date: Mon, 11 Nov 2013 21:02:19 +0000
Message-ID: <1384203736.7614.15.camel@leira.trondhjem.org>
References: <E4BE40FF-9F81-4688-BD39-1E583DDCEA4A@oracle.com>
	 <6EE5262F-5B2E-4F10-A600-A60F30C0A23E@netapp.com>
	 <2EFADFB9-6520-4ED3-A7A0-B87451885DFB@oracle.com>
In-Reply-To: <2EFADFB9-6520-4ED3-A7A0-B87451885DFB@oracle.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-11-11 at 15:35 -0500, Chuck Lever wrote:
+AD4- On Nov 11, 2013, at 12:33 PM, +ACI-Myklebust, Trond+ACI- +ADw-Trond.Myklebust+AEA-netapp.com+AD4- wrote:
+AD4- 
+AD4- +AD4- 
+AD4- +AD4- On Nov 11, 2013, at 11:50, Chuck Lever +ADw-chuck.lever+AEA-oracle.com+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4APg- Hi-
+AD4- +AD4APg- 
+AD4- +AD4APg- It was recently pointed out to me that the behavior of atime on NFS mount points is pretty dodgy, yet this is not documented anywhere, not even in the venerable and unmaintained Linux NFS FAQ.
+AD4- +AD4APg- 
+AD4- +AD4APg- A good place to cover this topic might be nfs(5).  It could discuss how the Linux NFS client deals with the various +ACo-atime mount options (mostly be collapsing them into relatime, all the time).  And it could discuss how file timestamps are updated when the physical backing store is on another system.
+AD4- +AD4APg- 
+AD4- +AD4APg- Thoughts?  Comments?
+AD4- +AD4- 
+AD4- +AD4- NFS atime is not the same as relatime.
+AD4- +AD4- 
+AD4- +AD4- Our atime is only updated when a READ rpc call goes to the server. Cached reads do not, for instance, trigger an atime update. That is a very different model than the relatime model.
+AD4- 
+AD4- Yes, but /proc/mounts shows the +ACI-relatime+ACI- option on NFS mounts.  And apparently it doesn't go away if you specify +ACI-noatime,+ACI- for example.
+AD4- 
+AD4- Basically it looks to some people like NFS ignores all the atime mount options.  We should document how NFS behaves, or fix it.

We +AF8-should+AF8- ignore all atime mount options. 

I'm fine with documenting the behaviour somewhere, but my point was that
documenting it in terms of +ACI-relatime+ACI- is not correct. We could, however,
clear that default MNT+AF8-RELATIME flag that 'do+AF8-mount' conveniently sets
for us.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
