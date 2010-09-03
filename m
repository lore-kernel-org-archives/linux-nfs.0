Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25987 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836Ab0ICPC0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 11:02:26 -0400
Subject: Re: [PATCH 1/1] mount: RDMA processing in the mount command is broken
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C801F67.50604@RedHat.com>
Date: Fri, 3 Sep 2010 11:01:12 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <E8DF9F75-7AFE-48C8-B659-90E73EC4F502@oracle.com>
References: <1283457651-12010-1-git-send-email-steved@redhat.com> <E401A220-AAD8-42F1-AE81-3B1EEF209428@oracle.com> <4C801F67.50604@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 2, 2010, at 6:04 PM, Steve Dickson wrote:

> 
> 
> On 09/02/2010 04:35 PM, Chuck Lever wrote:
>> 
>> On Sep 2, 2010, at 4:00 PM, Steve Dickson wrote:
>> 
>>> The mounting code that process RMDA mounts is broken in a few places
>>> 
>>> First with '-o proto=rdma' was broken because nfs_get_proto()
>>> did not how to convert a netid of 'rdma' in to a AF_INET
>>> address family.
>>> 
>>> Secondly, '-o rdma' was broken because po_get() was being using
>>> to detect the existence of 'rdma' in the options. With '-o rdma'
>>> there is no value associated with that option so po_get()
>>> was always return NULL.
>> 
>> Looking at nfs(5), "rdma" as a stand-alone option isn't documented.  Only "proto=rdma" appears to be mentioned.  Thus I would argue that this is already behaving correctly.
>> 
>> Are you proposing to add support for "-o rdma" ?  If so what would that mean?
> See Documentation/filesystems/nfs/nfs-rdma.txt
> 
> I see no problem in handing this same why we handle 'udp' and 'tcp'

I used nfs(5) as the specification for the text-based option parsing support in the mount.nfs command, since that's generally what administrators and packagers look to when trying to figure out how to use mount.

I don't see any evidence in utils/mount/* that a stand-alone "rdma" option was ever supported.  The kernel documentation could be wrong, or could be based on the kernel's mount option parser, which does support a stand-alone "rdma" mount option.  So, my opinion is that, today, mount.nfs is not misbehaving by rejecting the "rdma" mount option.  This is not a bug, it's working as designed.

To add an "rdma" mount option, therefore, is really introducing a new feature to mount.nfs.  So, I think such a patch needs appropriate changes to user documentation, and this mode of invoking rdma needs testing, since clearly no-one noticed it was missing until now.

As with the rpc.nfsd changes, these mount option changes are two logically distinct but related changes that belong in separate patches.

-- 
chuck[dot]lever[at]oracle[dot]com




