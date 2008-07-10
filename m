From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Thu, 10 Jul 2008 13:27:47 -0400
Message-ID: <C5841A2A-5178-405F-A5A5-1E8D1B77A419@oracle.com>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net> <20080703204543.GI30918@fieldses.org> <1215454820.19512.25.camel@localhost> <F84C7866-E340-49BF-B542-308E10AC9518@oracle.com> <1215456693.19512.36.camel@localhost> <76bd70e30807071244v4db1c366uc7599d2dd806bf1b@mail.gmail.com> <1215463877.19512.40.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:32653 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbYGJR3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 13:29:09 -0400
In-Reply-To: <1215463877.19512.40.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 7, 2008, at 4:51 PM, Trond Myklebust wrote:

> On Mon, 2008-07-07 at 15:44 -0400, Chuck Lever wrote:
>
>> If you would like connected UDP, I won't object to you implementing
>> it.  However, I never tested whether a connected UDP socket will give
>> the desired semantics without extra code in the UDP transport (for
>> example, an ->sk_error callback).  I don't think it's worth the  
>> hassle
>> if we have to add code to UDP that only this tiny use case would  
>> need.
>>
>
> OK. I'll set these patches aside until I have time to look into adding
> connected UDP support.

That's not completely necessary... the one-shot + TCP changes just  
make it nicer when the local rpcbind is not listening.  Without these,  
the cases where the rpcbind daemon isn't running, or doesn't support  
rpcbind v3/v4 and the kernel was built with CONFIG_SUNRPC_REGISTER_V4,  
will cause some delays before failing, but otherwise shouldn't be a  
problem.

I think you can drop the patch to change rpcb registration to go over  
TCP for now unless you already have a CUDP implementation you are  
happy with.

I know a lot of folks are waiting for IPv6 support to appear, and I  
don't want this detail to hang it up.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
