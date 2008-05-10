From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Sat, 10 May 2008 16:50:13 -0700
Message-ID: <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com>
References: <20080509011918.GK12690@fieldses.org> <1210309839.8657.0.camel@localhost> <20080509152750.GA325@fieldses.org> <20080509165204.GB1907@fieldses.org> <20080509171208.GC1907@fieldses.org> <20080509235930.GM1907@fieldses.org> <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com> <1210440728.12927.5.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Manoj Naik <manoj@almaden.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:17163 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbYEJXuy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 May 2008 19:50:54 -0400
In-Reply-To: <1210440728.12927.5.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 10, 2008, at 10:32 AM, Trond Myklebust wrote:
> On Fri, 2008-05-09 at 19:29 -0700, Chuck Lever wrote:
>> Should you use in4_pton() instead?
>
> Can we rather convert this to use nfs_parse_server_address? We don't
> need 10 different ways to parse text addresses...

I'm OK with that, as long as there isn't a technical problem with  
using in4_pton().

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
