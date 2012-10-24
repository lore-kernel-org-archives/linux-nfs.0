Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29939 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756738Ab2JXMmP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 08:42:15 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Brock Noland <brock@cloudera.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: readdir from Linux NFS4 client when cookieverf is no longer
 valid
Date: Wed, 24 Oct 2012 12:42:13 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA90928F4E6@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAFukC=5Mq3CwK=u7YP_=cF6gab+0K_mP-Sj0k8fCk_a2f=xsfg@mail.gmail.com>
In-Reply-To: <CAFukC=5Mq3CwK=u7YP_=cF6gab+0K_mP-Sj0k8fCk_a2f=xsfg@mail.gmail.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Brock Noland
> Sent: Tuesday, October 23, 2012 8:08 PM
> To: linux-nfs@vger.kernel.org
> Subject: readdir from Linux NFS4 client when cookieverf is no longer valid
> 
> Hello,
> 
> It is my first message to this list, so please understand I that I might be in the
> wrong place or be wrong altogether. In my spare time I am implementing a
> NFS Proxy for the Hadoop Distributed File System:
> https://github.com/brockn/hdfs-nfs-proxy The scenario is as follows, two
> clients RHEL 6.3 and 5.8:
> 
> Client 1) Creating and deleting files in a directory Client 2) Listing the files in
> that directory with a wildcard: foo*
> 
> Eventually client 1 creates a file while client 2 is listing the directory.
> 
> Regarding readdir from a NFS4 client, based on RFC 3530 it is my
> understanding that if the cookie verifier is invalid, I should return
> NFS4ERR_NOT_SAME. I believe that because of this statement "If the server
> determines that the cookieverf is no longer valid for the directory, the error
> NFS4ERR_NOT_SAME must be returned." In my case, I am using the number
> of entries in the directory as the cookieverf.
> Based on the statement above, it was my belief that the client should then
> re-read the directory.

This discussion comes up pretty much every time someone writes a new NFS server and/or filesystem. The thing that neither RFC1813, RFC3530, or RFC5661 have done is come up with sane semantics for how a NFS client is supposed to recover from the above scenario. What do I do with things like telldir()/seekdir() cookies? How do I recover my 'current position' in the readdir() stream?
IOW: how do I fake up POSIX semantics to the applications?

Until the recovery question is answered, the Linux client will continue to ignore the whole "cookie verifier" junk...

Trond
