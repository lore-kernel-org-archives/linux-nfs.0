From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 34/38] svc: Add /proc/sys/sunrpc/transport files
Date: Mon, 3 Dec 2007 15:36:59 -0500
Message-ID: <3F7E5DF2-0F8E-4C84-9F3B-0AD0985321B2@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224105.14563.48684.stgit@dell3.ogc.int> <C3F9B0D5-6CBD-4BBC-B00E-DCA16DD78EBF@oracle.com> <20071203165853.GE16422@fieldses.org> <1C15F1D5-88CC-4FD1-A7B9-508694A1A009@oracle.com> <1196709058.5811.21.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:26312 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbXLDAWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 19:22:52 -0500
In-Reply-To: <1196709058.5811.21.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 3, 2007, at 2:10 PM, Tom Tucker wrote:
> On Mon, 2007-12-03 at 13:30 -0500, Chuck Lever wrote:
>> On Dec 3, 2007, at 11:58 AM, J. Bruce Fields wrote:
>>> On Mon, Dec 03, 2007 at 11:44:15AM -0500, Chuck Lever wrote:
>>>> One last one, then I will crawl back into my hole.
>>>
>>> By the way, based on who I recall making a lot of comments, I'm
>>> planning
>>> on just adding:
>>>
>>> 	Acked-by: Neil Brown <neilb@suse.de>
>>> 	Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>> 	Reviewed-by: Greg Banks <gnb@sgi.com>
>>>
>>> to all of the server transport-switch and rdma patches.  Does that
>>> sound
>>> right?
>>
>> OK for the transport switch.  I'm not qualified to review the bulk of
>> the RDMA work, so I would prefer that you don't add Reviewed-by "me"
>> for those patches.  My eyes glazed over a few lines after the GPL
>> boilerplate.
>>
>>> And I'm assuming there are no objections to submitting this come the
>>> next merge window.
>>
>> Refactoring the server-side write space logic has exposed some
>> problems that really shouldn't be allowed to stand.  I think we
>> should resolve the issues in the TCP write space callback before
>> merging.  Realistically those problems are non-architectural and
>> should be fixable before the window opens.
>
> Could you be more specific on what these problems are?

The problems we discussed on Friday about svc_tcp_has_wspace(),  
introduced in 9/38.

The mess is hidden by implicit type casts in the write space check,  
replaced by 9/38, in svc_sock_enqueue().   The return type of  
svc_sock_wspace() is unsigned long, which means the other side of the  
comparison in svc_sock_enqueue() (the sum that becomes "required" in  
your patch) is implicitly promoted to unsigned long before the  
comparison is done.

Your patch misses the implicit cast at least by making "required" an  
int in the new callback functions.  "required" should be an unsigned  
long in both the UDP and TCP callback to preserve the semantics of  
the existing logic.

It's also the case that sk_stream_wspace() can return a negative  
value if sk_wmem_queued somehow becomes larger than sk_sndbuf.   
However, in the existing svc_sock_enqueue() logic, a negative result  
from sk_stream_wspace() is converted to an unsigned long, making it a  
large positive number.  The server then thinks it may continue  
writing to a socket whose buffer is already full.

I'm also worried about whether sk_reserved, which is an int and is  
incremented and decremented without a check to see if it has gone  
negative, can go negative during normal operation -- and if it does,  
what does that do to the value of "required" and the result of the  
write space check, in either the UDP or TCP case?

In addition, the server's TCP write space check is missing a  
comparison that every other TCP write space callback in the kernel  
has (comparing sk_stream_wspace and sk_stream_min_wspace).  If we  
don't include it here, then we need some testing to validate that it  
isn't needed, and a comment to explain why this write space callback  
is different from the others.

I was hoping for some comment from Neil or Bruce.

 From Friday's post:
> If sk_reserved goes negative, it will be converted to unsigned, and  
> become a very large positive number.  The result of the sum will be  
> recast back to an int when it's assigned to "required," and we  
> probably get a reasonable result.  I doubt an explicit cast will  
> change things at all.
>
> Instead, perhaps we should add an explicit check to ensure  
> sk_reserved is a reasonable positive value before doing any other  
> checks.  (Likewise in the UDP case as well).
>
> I wonder if this is really the correct write space check to use for  
> TCP, though.  I remember fixing a similar issue in the RPC client a  
> long time ago -- both UDP and TCP used the same wspace check.  It  
> resulted in the sk_write_space callback hammering on the RPC  
> client, and forward progress on TCP socket writes would slow to a  
> crawl.
>
> You probably want something like this instead:
>
> 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
>
> 	required = atomic_read(&svsk->sk_reserved) + serv->sv_max_mesg;
> 	wspace = sk_stream_wspace(svsk->sk_sk);
>
> 	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> 		return 0;
> 	if (required * 2 > wspace)
> 		return 0;
>
> 	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> 	return 1;
>
> The first test mimics sk_stream_write_space() and xs_tcp_write_space 
> ().  I'm still unsure what to do about the possibility of one of  
> these signed integers going negative on us.


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
