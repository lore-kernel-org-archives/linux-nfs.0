From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Thu, 12 Feb 2009 15:11:37 -0500
Message-ID: <D4DD97F7-B10B-43B5-B8F9-B7A489355A5E@oracle.com>
References: <20090211112318.GA29133@janus> <20090211203555.GC27686@fieldses.org> <20090211203703.GA9662@janus> <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus> <1234451789.7190.38.camel@heimdal.trondhjem.org> <20090212153634.GB28107@janus> <1234462647.7190.53.camel@heimdal.trondhjem.org> <20090212182943.GA1945@janus> <1234465837.7190.62.camel@heimdal.trondhjem.org> <03CEE6BB-D39D-47A5-BB6C-2FB3E206142F@oracle.com> <1234467795.7190.70.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28268 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbZBLUL6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2009 15:11:58 -0500
In-Reply-To: <1234467795.7190.70.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 12, 2009, at 2:43 PM, Trond Myklebust wrote:
> On Thu, 2009-02-12 at 14:35 -0500, Chuck Lever wrote:
>> I wasn't sure exactly where the compared addresses came from.  I had
>> assumed that they all came through the listener, so we wouldn't need
>> this kind of translation.  It shouldn't be difficult to map addresses
>> passed in via nlmclnt_init() to AF_INET6.
>>
>> But this is the kind of thing that makes "falling back" to an AF_INET
>> listener a little challenging.  We will have to record what flavor  
>> the
>> listener is and do a translation depending on what listener family  
>> was
>> actually created.
>
> Why? Should we care whether we're receiving IPv4 addresses or IPv6
> v4-mapped addresses? They're the same thing...

The problem is the listener family is now decided at run-time.  If an  
AF_INET6 listener can't be created, an AF_INET listener is created  
instead, even if CONFIG_IPV6 || CONFIG_IPV6_MODULE is enabled.  If an  
AF_INET listener is created, we get only IPv4 addresses in svc_rqst- 
 >rq_addr.

So we can do it either way.  Taking lockd as an example:

1.  Have nlmclnt_init() map AF_INET mount addresses to AF_INET6 iff  
the lockd listener is AF_INET6, so nlm_cmp_addr() is always dealing  
with AF_INET6 in this case, or

2.  If CONFIG_IPV6 || CONFIG_IPV6_MODULE, unconditionally map AF_INET  
addresses in nlmclnt_init and for incoming NLM requests (when lockd  
happens to have fallen back to an AF_INET listener)

Personally I think solution 1. will be less confusing operationally  
and less invasive code-wise.  I suppose IPv6 purists would prefer  
keeping the whole stack in AF_INET6, so they would like solution 2.

Eventually we could map incoming addresses on AF_INET listeners in the  
RPC server code, but I prefer to wait until all kernel RPC services  
have IPv6 support.

Since 2.6.29 has the CONFIG_SUNRPC_REGISTER_V4=N workaround, do we  
need to fix 2.6.29, or can this wait until 2.6.30?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
