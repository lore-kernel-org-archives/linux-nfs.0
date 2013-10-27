Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:1391 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753161Ab3J0Msv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Oct 2013 08:48:51 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Eshel Marc <eshel@us.ibm.com>
CC: Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "Wheeler Ric" <ricwheeler@gmail.com>
Subject: Re: XATTRs in NFS?
Date: Sun, 27 Oct 2013 12:48:49 +0000
Message-ID: <4260556F-D57B-407E-A686-808D3D802137@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
 <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
 <1382635350.6907.83.camel@heisenberg.scientia.net>
 <20131025140846.GB20497@fieldses.org> <526A8D9A.8090008@gmail.com>
 <7C1323EE-D63F-4F93-A44D-E7DDB0C61BF0@netapp.com>
 <OF01D9818B.36018C0F-ON88257C10.00608BC0-88257C10.006139C6@LocalDomain>
 <OF7F1977B0.3BF0FF3B-ON88257C10.00618038-88257C10.0061AF59@us.ibm.com>
In-Reply-To: <OF7F1977B0.3BF0FF3B-ON88257C10.00618038-88257C10.0061AF59@us.ibm.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 26, 2013, at 1:46 PM, Marc Eshel <eshel@us.ibm.com> wrote:

> linux-nfs-owner@vger.kernel.org wrote on 10/26/2013 06:20:12 AM:
> 
>> I'd rather look bad for not supporting a broken filesystem feature 
>> than have to deal with the abiove mentioned side-effects. Until the 
>> xattr interface is properly documented and standardised so that it 
>> can be exported safely, it should be treated as a unexportable, in 
>> the same way we treat procfs and sysfs.
>> 
> 
> This sounds more like an NFS server problem than a client side NFS. Can we 
> add support to the client side NFS and let server that think that they can 
> handle XATTR implement it?

No. It's a real problem for clients too if the NFS server starts exporting ACLs and security labels via this interface. Everything from integer endianness problems when getfacl attempts to read raw binary acls from the server, to breakage of caching models when we allow setfacl and don't invalidate our file access caches...

> We should probably start a discussion in the IETF to resolve the issues 
> you see with XATTR at least for NFSv4.3. 

Let's get the basic discussion of motivation right first.

Trond