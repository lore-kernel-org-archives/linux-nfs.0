Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:65221 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab1KGSCM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 13:02:12 -0500
Subject: Re: rpcbind -h
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111107172131.GA1008@umich.edu>
Date: Mon, 7 Nov 2011 13:01:58 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <17F52BED-5ED9-4FBA-A959-B31A88C800B1@oracle.com>
References: <20111106155844.GA1790@umich.edu> <3096DDEC-48D3-423A-B674-160B8DA59DE2@oracle.com> <20111107172131.GA1008@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 7, 2011, at 12:21 PM, Jim Rees wrote:

> Chuck Lever wrote:
> 
>  On Nov 6, 2011, at 10:58 AM, Jim Rees wrote:
> 
>> Is there some good reason why the rpcbind '-h' option (bind to given
>> address) applies only to the udp listening socket and not to the tcp socket?
> 
>  Yes.  See the mail archives.  I believe we've discussed this thoroughly
>  within the past six months to a year.  If there's any bug here, it's that
>  "-h" is not well documented.
> 
> It's documented well enough but I'm still in the dark about the reason.  I
> don't recall the discussion and can't find it in the archives.  The search
> box on spinics isn't working for me, it returns results from the entire web,
> not just the list archive.
> 
> As I said before, I was hoping for the equivalent of "portmap -l".  I was
> ready to code up a patch of some kind but now have a workaround (mount with
> nolock and don't run rpcbind at all).

I wouldn't object to having a "local only" option that turns off the AF_INET[6] listener and just listens on the AF_LOCAL socket, but that may be problematic until we have a complete transition away from glibc RPC, which still uses AF_INET loopback extensively.

Glad you found a work-around.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




