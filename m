From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not specified by user
Date: Wed, 2 Sep 2009 10:16:18 -0400
Message-ID: <0282C3B6-2DC1-4C75-B8D8-952CF74A213A@oracle.com>
References: <20090901151830.GC22846@fieldses.org> <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com> <20090901160914.GG22846@fieldses.org> <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com> <20090901163846.GJ22846@fieldses.org> <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com> <1251829540.18608.31.camel@heimdal.trondhjem.org> <D11105A9-4FAB-4F5C-BF02-BE489520C150@oracle.com> <1251833479.18608.69.camel@heimdal.trondhjem.org> <E7FCF468-0A25-4DA1-8E71-A383BCBA4642@oracle.com> <20090901201544.GF27726@fieldses.org> <411DA127-278F-4799-9E40-EB8409510E2E@oracle.com> <1251840160.8463.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:27718 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbZIBOQd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 10:16:33 -0400
In-Reply-To: <1251840160.8463.20.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 1, 2009, at 5:22 PM, Trond Myklebust wrote:
> On Tue, 2009-09-01 at 16:31 -0400, Chuck Lever wrote:
>> For v4, you have WRONGSEC, but I don't think NFSv2 makes that
>> distinction.  Would the client probe the server with NFS requests  
>> each
>> using a different flavor?  Would we expect to see the RPC level "weak
>> authentication" reply in the NFSv2 case?  Before Eisler says it, why
>> would we bother?
>>
>> Even so, that's a much different proposition than simply reading the
>> flavor list returned by MNT3PROC, so I'm straining to see how we  
>> could
>> reuse the logic I'm adding to the kernel's MNT client to do security
>> negotiation for NFSv2.  If Trond is referring only to merging the
>> kernel's auth flavor lists, then that comment makes more sense.
>
> IMO the goal should be to have _one_ engine that can iterate through a
> list of auth flavours (either the list provided by the MNT server, or
> the list of all flavours supported by the client) until it gets a
> positive response to an RPC call.

OK, but that's not what the MNT client has to do with the list  
returned from MNT3PROC.  All it needs to do is check the requested  
auth flavor against the returned list, or pick the first supported  
flavor on the list if the user didn't request one.

So my practical question still remains.  For 2.6.32, how should the  
kernel's MNT client determine the list of supported authentication  
flavors?  (I understand that one answer might be "we can't do an  
adequate job of that at this point, so we probably should drop MNT  
authlist support until we can").

> We shouldn't assume that the flavour
> that was negotiated at mount time is final.

Why not?  That's how NFSv2 and NFSv3 have worked forever.  And, how  
will client admins enforce the use of a particular security flavor if  
they can't be sure that the client won't renegotiate it?

For NFSv3, you can save the list of supported flavors returned by  
MNT3PROC on the client to do renegotiation later, but what happens  
when the server admin changes the auth flavors for an export that the  
client has already mounted?

> It makes sense to code this iteration process at the RPC level instead
> of at the NFS level. That enables us to use the same engine for NFSv2,
> NFSv4, and the NFSv4.0 server (when doing client callbacks). Possibly
> also for NLM and MOUNT (apparently IRIX used to support this)...

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



