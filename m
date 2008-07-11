From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Fri, 11 Jul 2008 14:40:54 -0400
Message-ID: <20080711184054.GA19425@fieldses.org>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net> <20080703204543.GI30918@fieldses.org> <1215454820.19512.25.camel@localhost> <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com> <1215456693.19512.36.camel@localhost> <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com> <1215463877.19512.40.camel@localhost> <C5841A2A-5178-405F-A5A5-1E8D1B77A419@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57674 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862AbYGKSlI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 14:41:08 -0400
In-Reply-To: <C5841A2A-5178-405F-A5A5-1E8D1B77A419@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2008 at 01:27:47PM -0400, Chuck Lever wrote:
>
> On Jul 7, 2008, at 4:51 PM, Trond Myklebust wrote:
>
>> On Mon, 2008-07-07 at 15:44 -0400, Chuck Lever wrote:
>>
>>> If you would like connected UDP, I won't object to you implementing
>>> it.  However, I never tested whether a connected UDP socket will give
>>> the desired semantics without extra code in the UDP transport (for
>>> example, an ->sk_error callback).  I don't think it's worth the  
>>> hassle
>>> if we have to add code to UDP that only this tiny use case would  
>>> need.
>>>
>>
>> OK. I'll set these patches aside until I have time to look into adding
>> connected UDP support.
>
> That's not completely necessary... the one-shot + TCP changes just make 
> it nicer when the local rpcbind is not listening.  Without these, the 
> cases where the rpcbind daemon isn't running, or doesn't support rpcbind 
> v3/v4 and the kernel was built with CONFIG_SUNRPC_REGISTER_V4, will cause 
> some delays before failing, but otherwise shouldn't be a problem.
>
> I think you can drop the patch to change rpcb registration to go over  
> TCP for now unless you already have a CUDP implementation you are happy 
> with.

So actually in your original series of 7 I think that'd mean dropping
numbers 5 and 6 and keeping the rest?

I've lost track of the status of the 3 series you submitted on the 30th:

	"Remaining rpcbind patches for 2.6.27"
		- this one, probably ready after dropping 2 patches
	"rpcbind v4 support in net/sunrpc/svc*"
		- Do you still want this considered for 2.6.27?
	"NLM clean-ups for IPv6 support"
		- I think you were saying there's still a bug being
		  tracked down in this series?

--b.
