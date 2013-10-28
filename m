Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756779Ab3J1Pm0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 11:42:26 -0400
Message-ID: <526E85A4.4090906@redhat.com>
Date: Mon, 28 Oct 2013 11:41:24 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: James Morris <jmorris@namei.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Eshel Marc <eshel@us.ibm.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>
Subject: Re: XATTRs in NFS?
References: <1382560643.6924.12.camel@heisenberg.scientia.net> <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com> <1382624000.6907.8.camel@heisenberg.scientia.net> <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com> <1382630468.6907.58.camel@heisenberg.scientia.net> <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com> <1382635350.6907.83.camel@heisenberg.scientia.net> <20131025140846.GB20497@fieldses.org> <526A8D9A.8090008@gmail.com> <7C1323EE-D63F-4F93-A44D-E7DDB0C61BF0@netapp.com> <OF01D9818B.36018C0F-ON88257C10.00608BC0-88257C10.006139C6@LocalDomain> <OF7F1977B0.3BF0FF3B-ON88257C10.00618038-88257C10.0061AF59@us.ibm.com> <4260556F-D57B-407E-A686-808D3D802137@netapp.com> <alpine.LRH.2.02.1310290022270.18164@tundra.namei.org>
In-Reply-To: <alpine.LRH.2.02.1310290022270.18164@tundra.namei.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2013 09:25 AM, James Morris wrote:
> On Sun, 27 Oct 2013, Myklebust, Trond wrote:
>
>>> This sounds more like an NFS server problem than a client side NFS. Can we
>>> add support to the client side NFS and let server that think that they can
>>> handle XATTR implement it?
>> No. It's a real problem for clients too if the NFS server starts
>> exporting ACLs and security labels via this interface. Everything from
>> integer endianness problems when getfacl attempts to read raw binary
>> acls from the server, to breakage of caching models when we allow
>> setfacl and don't invalidate our file access caches...
> Right, so any general xattrs for nfs would need to be specified as having
> no system effects, essentially exporting the Linux 'user' xattr namespace
> only.
>
>
>>> We should probably start a discussion in the IETF to resolve the issues
>>> you see with XATTR at least for NFSv4.3.
>> Let's get the basic discussion of motivation right first.
> It should be for user-managed metadata only.
>

That would be what I would like to see over NFS...

ric

