From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] nfsd: make nfs4xdr WRITEMEM safe against zero count
Date: Mon, 2 Jun 2008 13:51:53 -0400
Message-ID: <8B506085-8EDB-4FD2-97B7-1A91EA05DA4C@oracle.com>
References: <483E7DB8.1050705@panasas.com> <3C91B431-664C-4D9C-B85A-4152B4624168@oracle.com> <20080602164909.GE18887@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62471 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbYFBRzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2008 13:55:24 -0400
In-Reply-To: <20080602164909.GE18887@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 2, 2008, at 12:49 PM, J. Bruce Fields wrote:
> On Thu, May 29, 2008 at 12:24:58PM -0400, Chuck Lever wrote:
>> By the way, here is a pointer to the old work:
>>
>>  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=drop-20070423
>>
>> The work in this snapshot is only partially complete.
>>
>> There are many many issues to fix up.  One of the bigger ones is that
>> the RPC layer still takes the BKL during XDR encoding and  
>> decoding.  But
>> I wanted to create something that could be fully or partially  
>> shared by
>> the client and server implementations, and that would be more  
>> rigorous
>> about static and dynamic type checking.
>>
>> In addition, the NFSv4 routines use a new style of managing the RPC
>> buffer that I wanted to adopt for the other in-kernel XDR routines,  
>> then
>> convert the RPC client to use only the new style when invoking XDR
>> routines.  I never got that far, but I still think it's a reasonable
>> goal.
>
> To find something manageable to start with, what's the minimum first
> step that that would achieve Benny's goal of replacing those server- 
> side
> xdr macros?

If we're going to do this, I think we want to replace the macros in  
both the server and the client.

Thus you want to have a set of shared static inline functions that  
manage static type checking, data conversion, and bounds checking for  
basic XDR data types.  There are a short series of patches near the  
beginning of that branch that introduce these helpers.  Look at  
06e537f7 through cf1ba5ab.

The last one adds generic warning messages on XDR encode and decode  
errors.  We can certainly remove (or provide a kernel config switch  
for) the decode warnings as they could cause a DoS, but the encode  
error messages might be useful, and would allow us to remove many of  
the ad hoc printk's from the XDR functions themselves, resulting in  
smaller code.

Then, 986ac05e defines the set of NFSv4 XDR data types laid out in  
RFC3530.  The following patches start to fix up the client-side  
encoders; I didn't get to the client-side decoders, or to the server.

The real effort is going to be reworking the encoders and decoders for  
the big NFSv4 datatypes, like for instance the arguments and results  
that contain attributes.

> From a quick glance at the patches: a kerneldoc comment for each xdr
> encode/decode seems like overkill, since it's mostly boilerplate;  
> could
> we document those arguments just once with the definition of  
> kxdrproc_t,
> then refer to that comment as necessary?

A lot of the changes in that drop are excessive; it was a prototype,  
so I used the comments to keep track of where I was heading.  However,  
in general I think it's important to document the assumptions relating  
to the arguments, and the possible return values, for each public  
function.

Many of the comments in these patches also copy the definition of the  
XDR data type from the RFC, and call out the RFC section where it is  
specified.  This provides a clear connection between the  
implementation and the spec to allow easier code review and maintenance.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
