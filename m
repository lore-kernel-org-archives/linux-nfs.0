From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Massive NFS problems on large cluster with large number of mounts
Date: Thu, 31 Jul 2008 12:35:10 -0400
Message-ID: <B32F9D83-9DB5-49D7-B6B8-64F27029BEA8@oracle.com>
References: <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost> <487DC43F.8040408@aei.mpg.de> <20080716190658.GF20298@fieldses.org> <76bd70e30807170747r31af3280icf0bd3fdbde17bac@mail.gmail.com> <20080717144852.GA11759@fieldses.org> <76bd70e30807170811s78175c0ep3a52da7c0ef95fc6@mail.gmail.com> <76bd70e30807281355t4890a9b2q6960d79552538f60@mail.gmail.com> <20080730175308.GH12364@fieldses.org> <76bd70e30807301233t73f92775tbdeb3f8efbb34a4f@mail.gmail.com> <20080730221304.GB20739@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: chucklever@gmail.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:24984 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbYGaQgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 12:36:20 -0400
In-Reply-To: <20080730221304.GB20739@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 30, 2008, at 6:13 PM, J. Bruce Fields wrote:
> On Wed, Jul 30, 2008 at 03:33:38PM -0400, Chuck Lever wrote:
>> On Wed, Jul 30, 2008 at 1:53 PM, J. Bruce Fields <bfields@fieldses.org 
>> > wrote:
>>> In any case, this all seems a bit orthogonal to the problem of what
>>> ports the rpcbind client uses, right?
>>
>> No, this is exactly the original problem.  The reason  
>> xprt_maxresvport
>> is allowed to go larger than 1023 is to permit more NFS mounts.   
>> There
>> really is no other reason for it I can think of.
>>
>> But it's broken (or at least inconsistent) behavior that max_resvport
>> can go past 1023 in the first place.  The name is "max_resvport" --
>> Maximum Reserved Port.  A port value of more than 1024 is not a
>> reserved port.  These sysctls are designed to restrict the range of
>> ports used when a _reserved_ port is requested, not when _any_ source
>> port is requested. Trond's suggestion is an "off label" use of this
>> facility.
>
> We could do a better job of communicating what is and isn't a  
> documented
> usage, in that case.
>
> Once people are already using an interface a certain way (and  
> because we
> told them to) discussions about whether it's really a correct use  
> start
> to seem a little academic.

It's not at all academic.

We _must_ revisit interface design whenever we have a design that  
results in a kernel paging exception, a privilege escalation or denial  
of service, or it's simply confusing or using standard terminology  
incorrectly.  It is always appropriate to talk about it.

What we need to be careful about when people are already using an  
interface is how we go about changing it.

>> And rpcbind isn't the only kernel-level RPC service that requires a
>> reserved port.  The kernel-level NSM code that calls user space, for
>> example, is one such service.  In other words, rpcbind isn't the only
>> service that could potentially hit this issue, so an rpcbind-only fix
>> would be incomplete.
>>
>> We already have an appropriate interface for kernel RPC services to
>> request a non-privileged port.  The NFS client should use that
>> interface.
>
> I admit that would be nicer.
>
> --b.
>
>> Now, we don't have to change both at the same time.  We can introduce
>> the mount option now; the default reserved port range is still good.
>> And eventually folks using the sysctl will hit the rpcbind bug (or a
>> lock recovery problem), trace it back to this issue, and change their
>> mount options and reset their resvport sysctls.
>>
>> At some later point, though, the maximum should be restricted to  
>> 1023.
>>
>>>> Such an "insecure" mount option would then set
>>>> RPC_CLNT_CREATE_NONPRIVPORT on rpc_clnt's created on behalf of  
>>>> the NFS
>>>> client.
>>>>
>>>> I'm not married to the names of the options, or even using a mount
>>>> option at all (although that seems like a natural place to put  
>>>> such a
>>>> feature).
>>>>
>>>> Thoughts?
>>
>> --
>> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



