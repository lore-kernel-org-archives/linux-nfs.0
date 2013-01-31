Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:38072 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab3AaPFq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2013 10:05:46 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH v2 0/9] Dynamically load GSS pseudoflavors by OID
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5FCBEC10-44F0-4CD8-BB97-2C49FA768373@oracle.com>
Date: Thu, 31 Jan 2013 10:05:39 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <EEEB1F96-709F-4E65-A7FC-D61343EB99E0@oracle.com>
References: <20130130231546.47786.6016.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA91834404D@sacexcmbx05-prd.hq.netapp.com> <5FCBEC10-44F0-4CD8-BB97-2C49FA768373@oracle.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 30, 2013, at 7:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> On Jan 30, 2013, at 6:51 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
>> Looks good! How have you tested it?
> 
> Start with a Solaris 11 NFS server and my client.  The server has a Kerberos-only share called /test/krb5-only.
> 
>  1.  "sudo rmmod auth_rpcgss" on the client (no NFS mounts at this point)

Bash history says I misremembered this.  I actually used:

  "sudo rmmod rpcsec_gss_krb5"

So, part of my next round of testing will try to remove both rpcsec_gss_krb5 and auth_rpcgss, if I can, and see if all the right things happen when I cross into a krb5-only file system.


>  2.  "sudo mount server:/ /mnt"
> 
>  3.  The client accesses the pseudo-fs with AUTH_UNIX (observed with wireshark)
> 
>  4.  After I kinit on the client, I cd into /test/krb5-only
> 
>  5.  The client encounters the WRONG_SEC and performs a SECINFO request (observed with wireshark)
> 
>  6.  The correct kernel modules are loaded, and the cd completes successfully.
> 
>  7.  I "cd ~" and unmount /mnt.  The module refcounts go to zero.
> 
> I've run this with debugging enabled and extra dprintk's, and it looks like the client is doing all the right things.
> 
> I'd like to extend the testing a bit with a Linux NFS server, now that there's a server-side change in this series.  And naturally I'll need broad compile-testing with various combinations of CONFIG options.  I'm open to suggestions of other use cases / corner cases.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




