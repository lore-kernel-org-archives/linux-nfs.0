From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 38/38] svc: Add svc_xprt_names service to replace
 svc_sock_names
Date: Mon, 14 Jan 2008 07:27:26 -0600
Message-ID: <C3B0BF5E.2B2AE%tom@opengridcomputing.com>
References: <18301.33306.486417.193770@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:18351 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbYANN1l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 08:27:41 -0500
In-Reply-To: <18301.33306.486417.193770-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Sorry for the delay...

On 1/3/08 6:47 PM, "Neil Brown" <neilb@suse.de> wrote:

> On Thursday January 3, bfields@fieldses.org wrote:
>> On Fri, Dec 21, 2007 at 11:51:47AM -0600, Tom Tucker wrote:
>>> 
>>> On Fri, 2007-12-14 at 19:03 -0500, J. Bruce Fields wrote:
>>>> On Tue, Dec 11, 2007 at 05:33:18PM -0600, Tom Tucker wrote:
>>>>> 
>>>>> Create a transport independent version of the svc_sock_names function.
>>>>> 
>>>>> The toclose capability of the svc_sock_names service can be implemented
>>>>> using the svc_xprt_find and svc_xprt_close services.
>>>> 
>>>> Should we delete the toclose checks from svc_sock_names(), then, under
>>>> the assumption it's always called with toclose non-NULL now?
>>>> 
>>>> And why can't we just completely replace svc_sock_names() at this point?
>>>> 
>>> 
>>> IMO we could, but there is currently a difference in behavior between
>>> svc_sock_names and svc_find_xprt/close. svc_find_xprt doesn't care what
>>> the IP address is, it only compares transport name, address family and
>>> port. 
>>> 
>>> Presently in NFS, we only ever listen on zero, but you can destroy an
>>> endpoint on a particular interface (IP address). Can anyone shed some
>>> light on why this is?
>> 
>> Dunno.  Neil?
> 
> The "-H" option to "rpc.nfsd" allow you to bind nfsd to a specific
> interface.
> I don't think any user-space tools current allow you to unbind a
> specific interface, but I wouldn't want to lose that functionality.
> 
> Why are we changing this.  Clear the toclose functionality of the
> svc_sock_names service can *NOT* be impletemented using svc_xprt_find
> and svc_xprt_close as _find_ doesn't check the port - so just leave
> things the way they are???

I think you mean check the IP address ... Correct?

> I haven't really been following this update
> much so maybe there is something I'm missing....

I don't think you're missing anything, however, I think there are two pieces
to this: a) what should the new API support, and b) should we move the
existing code to the new API.

The new API (svc_xprt_find) does not currently search based on IP address
and therefore cannot be used for b). I think it should, however, since
svc_xprt_create can be used to create a listener on a specific IP
address/interface. 

 
> 
> NeilBrown
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


