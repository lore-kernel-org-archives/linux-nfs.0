From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Tue, 20 May 2008 15:38:38 -0400
Message-ID: <6C0F215B-C450-4BF7-8099-F19CF1397403@oracle.com>
References: <20080509152750.GA325@fieldses.org> <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org> <20080509235930.GM1907@fieldses.org> <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com> <1210440728.12927.5.camel@localhost> <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com> <1d07ca700805101807s7c034b08sc531993aa81010b2@mail.gmail.com> <20080516195326.GD14228@fieldses.org> <CF603745-0163-469F-AC12-B4C5747038FC@oracle.com> <20080520024734.GA23457@fieldses.org> <F7A2B33E-BD03-473E-ABA3-F51DE366F2ED@oracle.com> <1211311935.23156.15.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"david m. richter" <richterd@gmail.com>, linux-nfs@vger.kernel.org,
	Manoj Naik <manoj@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:43501 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757193AbYETTjo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2008 15:39:44 -0400
In-Reply-To: <1211311935.23156.15.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 20, 2008, at 3:32 PM, Trond Myklebust wrote:
> On Tue, 2008-05-20 at 12:54 -0400, Chuck Lever wrote:
>
>> So, I haven't added IPv6 support in this area because it seems to
>> assume an IPv4 address here, and it needs to handle the case where
>> this might be a hostname (ie there should be a DNS resolution in this
>> path).
>>
>> If you're going to call in4_pton(), it really should call
>> nfs_parse_server_address() instead; then this path would magically
>> support IPv6 addresses as well.
>>
>> But in the long run, this path will need either an upcall or it will
>> have to use the key-based kernel DNS resolution facility (Jeff Layton
>> mentioned something like this over lunch last week).
>
> No. The correct way to do this is to replace the current code
> fs_locations handler so that we do the mount from userspace. In  
> addition
> to voiding the whole issue of in-kernel DNS resolution, that also has
> the benefit that it allows us to put policy decisions like which  
> server
> to mount from under administrator control in userspace.
>
> I've already started coding up a solution.

Okay, I remembered incorrectly.

I assume this new mechanism is intended to handle IPv6 addresses and  
DNS resolution correctly because it will invoke mount.nfs.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
