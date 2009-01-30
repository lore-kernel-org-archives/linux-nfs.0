From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6 support is built in
Date: Fri, 30 Jan 2009 16:30:10 -0500
Message-ID: <F0ED35C3-3E01-42E2-BE71-1C1273C1B495@oracle.com>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net> <1233347546.9741.31.camel@heimdal.trondhjem.org> <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com> <1233350290.9741.42.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:37053 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbZA3Va0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 16:30:26 -0500
In-Reply-To: <1233350290.9741.42.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 30, 2009, at Jan 30, 2009, 4:18 PM, Trond Myklebust wrote:
> On Fri, 2009-01-30 at 15:46 -0500, Chuck Lever wrote:
>> On Jan 30, 2009, at Jan 30, 2009, 3:32 PM, Trond Myklebust wrote:
>>> How about using something like a 'symbol_request(ipv6_getsockopt)'  
>>> to
>>> probe whether or not IPv6 is available.
>>
>> That's a good idea.  I was about to go looking for the right way to
>> check if the module is available.
>
> Note that this isn't really sufficient to prevent races. Somebody may
> remove the ipv6 module before we get so far as to setting up the
> sockets.

Right, I'm wondering if we need to use something heavyweight like  
try_module_get() here.

>> I've been discussing this with Steve.  He'd like some way for lockd  
>> to
>> recover if only an IPv4 mount is requested, but the logic to do this
>> (and to report real errors on IPv6 mounts, and to handle the NFSD
>> cases) might get complicated.  Plus, once we start lockd with an
>> AF_INET listener, we are stuck with IPv4-only until lockd is  
>> restarted
>> from scratch.
>>
>> I think we want any issues in this area to be handled at mount/export
>> time, and not specifically by lockd or the callback server.  What do
>> you think?
>
> Yes and no. I thought the motivation for doing what you currently do  
> was
> to avoid mixing AF_INET and AF_INET6 sockets, since the latter  
> listen on
> both IPv4 (via the IPv4 mapping) and IPv6?

AF_INET6 listeners can receive AF_INET packets too, but don't have  
to.  My motivation was to use a single listener so we don't have to  
support multiple family listeners for each transport protocol in the  
server-side code.  Also, having a separate IPv6-only listener means  
that someone can come along and hijack the IPv4 packets on that port.

It's just less of a headache with one listener.

> If so, it sounds to me as if
> we _must_ have lockd and the callback server set up IPv6 sockets
> whenever they are available.

That's what the code does now.  The problem is exactly what does  
"whenever they are available" mean?

Are you suggesting we shouldn't ever fall back to AF_INET?  (I'm OK  
with that answer, but would like a discussion).  This means that if I  
try an IPv4 mount on a system built with an IPv6 module, but the  
module is unloadable, all mounts (even IPv4) fail outright.   
Apparently a lot of folks blacklist their IPv6 modules.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
