From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Security negotiation
Date: Fri, 10 Jul 2009 17:37:15 -0400
Message-ID: <2BA1057E-5A8E-4780-B8F2-FCC8BA3846CC@oracle.com>
References: <4A578372.1020005@excfb.com> <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com> <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com> <4A57AADE.8080002@excfb.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17725 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbZGJVhW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2009 17:37:22 -0400
In-Reply-To: <4A57AADE.8080002-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 10, 2009, at 4:55 PM, Tom Haynes wrote:
> Chuck Lever wrote:
>>
>>> If mountd does not provide AUTH_SYS a mount request with no sec=  
>>> will fail.  Should it try the first one in the list instead?  What  
>>> if the first one is AUTH_NULL?
>>
>> In other words, I'm not sure what is the right behavior here.  What  
>> it does now is probably suboptimal.  I've browsed 2623 a bit, but  
>> it's not hitting me.
>
> So we (OpenSolaris) changed our behavior inadvertently to do the
> list in order. Which means we are trying AUTH_NONE against
> a Linux server. (Bug is here: http://bugs.opensolaris.org/bugdatabase/view_bug.do?bug_id=6834430)
>
> We are considering two changes:
>
> 1) Use our default flavor (user configurable)
> 2) Order the list by strength based on the flavors we support.
>
> The first option would get us to where you are going to be. AUTH_SYS  
> will
> probably be the default.

It's easy to implement, test, and explain in a man page.  I think the  
first option gives the least surprise (ie a negotiated result that is  
not what you expect and thus may expose your data).

> The second option would push AUTH_NONE to the end of the list, which
> corresponds to my thinking of it as a wild card.

The problem with the server's auth list is that it is a list of _all_  
flavors that the server supports.  That doesn't mean the client  
necessarily wants to use any of those by default, especially not  
AUTH_NONE.  We've hit a number of behavior bugs where the client is  
negotiating AUTH_NONE and users can see their files, but not update  
them, and no real explanation why.  Very confusing.

It might be better to have a subset of flavors that the client can  
negotiate, like AUTH_SYS and AUTH_GSS/Krb5.  The others are supported,  
but can't be used unless the client's administrator has explicitly  
asked for them.  Having a default of only AUTH_SYS is rather a  
degenerate case of this.

> But it also means that if AUTH_SYS is not our default, then we might  
> try
> Kerberized access first. I think that is a surprise.
>
> Also, if the server has already ordered the list based on the  
> preference it
> would like the client to try, then the client should honor that list  
> if no
> specific flavor is used.

I was wondering when a server would not want to order the flavor list  
by strongest to weakest.  We have the use case of the kerberos 5  
pseudoflavors:  clients should probably use krb5 over krb5p by  
default, as this provides good security without a lot of performance  
overhead.  But krb5p is stronger security than krb5.

> So, I would say algorithmically:
>
> 1) If the client specifies a flavor, it uses that if the server  
> supports it. If the
> server does not, the mount fails.
>
> 2) If the client has a default, it tries that first if the server  
> supports it. If the
> server does not, then:
>
> 3) The client walks the array of flavors and uses the first that it  
> supports
> and the server supports.


I think it would be polite to display a warning if step 3 gives you  
AUTH_NONE.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
