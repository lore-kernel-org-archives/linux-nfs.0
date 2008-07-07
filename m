From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Mon, 7 Jul 2008 14:43:50 -0400
Message-ID: <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net> <20080703204543.GI30918@fieldses.org> <1215454820.19512.25.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:13449 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181AbYGGSqH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2008 14:46:07 -0400
In-Reply-To: <1215454820.19512.25.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 7, 2008, at 2:20 PM, Trond Myklebust wrote:
> On Thu, 2008-07-03 at 16:45 -0400, J. Bruce Fields wrote:
>> On Mon, Jun 30, 2008 at 06:38:35PM -0400, Chuck Lever wrote:
>>> Hi Trond-
>>>
>>> Seven patches that implement kernel RPC service registration via  
>>> rpcbind v4.
>>> This allows the kernel to advertise IPv4-only services on hosts  
>>> with IPv6
>>> addresses, for example.
>>
>> This is Trond's baliwick, but I read through all 7 quickly and they
>> looked good to me....
>
> They look more or less OK to me too, however I'm a bit unhappy about  
> the
> RPC_TASK_ONESHOT name: it isn't at all descriptive.

Open to suggestions.  I thought RPC_TASK_FAIL_WITHOUT_CONNECTION was a  
bit wordy ;-)

> I also have questions about the change to a TCP socket here. Why not
> just implement connected UDP sockets?

Changing rpcb_register() to use a TCP socket is less work overall, and  
we get a positive hand shake between the kernel and user space when  
the TCP connection is opened.

Other services might also want to use TCP+ONESHOT for several short  
requests over a real network with actual packet loss, but they might  
find CUDP+ONESHOT less practical/reliable (or even forbidden in the  
case of NFSv4).  So we would end up with something of a one-off  
implementation for rpcb_register.

The downside of using TCP in this case is that it's more overhead:  8  
packets instead of two for registration in the common case, and it  
leaves a single privileged port in TIME_WAIT for each registered  
service.  I don't think this matters much as registration happens  
quite infrequently.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
