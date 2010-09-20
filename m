Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:47145 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab0ITT3A convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 15:29:00 -0400
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C97B248.1030801@parallels.com>
Date: Mon, 20 Sep 2010 15:28:00 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Message-Id: <EE0DC983-8CFA-42FA-8D64-F4E2564E6FB0@oracle.com>
References: <4C90BADB.10700@parallels.com> <20100920161326.GL4580@fieldses.org> <4C978CE6.5080508@parallels.com> <20100920180418.GN4580@fieldses.org> <4C97B248.1030801@parallels.com>
To: Pavel Emelyanov <xemul@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2010, at 3:13 PM, Pavel Emelyanov wrote:

> On 09/20/2010 10:04 PM, J. Bruce Fields wrote:
>> On Mon, Sep 20, 2010 at 08:33:42PM +0400, Pavel Emelyanov wrote:
>>>>> Looking forward to your feedback.
>>>> 
>>>> What are you thinking of as a use-case for this?
>>> 
>>> To make it possible run both NFS server and client in containers.
>> 
>> Could you describe that in user-visible terms?  (Currently if I create a
>> new network namespace, what happens, and what will happen differently
>> afterwards?)
> 
> This is not about the network namespace only I believe. E.g. the
> nfsd filesystem is a filesystem already and shouldn't be tied to
> any task-driven context.
> 
> E.g. as far as the net namespace part is concerned. First of all
> the TCP/UDP socket used by transport will be per-namespace. User
> will "feel" this for example by different routing and netfilter
> rules applied to connections. Besides the rpc service sockets will
> be per namespace as well.
> 
>>> Sure! The thing is that the full containerization of that stuff is
>>> too many patches and I'm not sure that you and other maintainers wish
>>> to review the 100-patch set in one go ;)
>> 
>> Well, if it's really all ready....
>> 
>> Better, though, would be an outline of the work to be done and what you
>> expect to be working at the end.
> 
> The nearest plan is
> 
> 1. Prepare the sunrpc layer to work in net namespaces
> 2. Make rpcpipefs and nfsd filesystems be mountable multiple times
> 3. Make support for multiple instances of the nfsd caches
> 4. Make suuport for multiple instances of the nfsd_serv
> 
> After this several NFSd-s can be used in containers (hopefully I
> didn't miss anything).

Are you assuming NFSv4 only?  Something needs to be done about NLM and NSM to make this work right.

Is there an issue for idmapper and svcgssd?  Probably not, but worth exploring.

And, how about AUTH_SYS certs?  These contain the host's name in them, and that depends on the net namespace.  NLM uses AUTH_SYS, and I believe the NFS server can make NLM calls to the client.

> Plans about the nfs client are much more obscure for now.
> 
>>> I want to find out what git tree to hack on and prepare small patch
>>> sets making things step-by-step. This one is just the first in a row.
>> 
>> For the server side you can use
>> 
>> 	git://linux-nfs.org/~bfields/linux.git nfsd-next
>> 
>> though generally the latest upstream will likely work as well.
> 
> OK, I will re-base the set onto the nfsd-next then.
> 
>> On a quick skim, those patches look fine (and brokenly up nicely for
>> review, thanks).  My main concern is just being sure I understand where
>> this all ends up.
> 
> Well, as far as I know the nfsd and sunrpc code the plan described
> above should give us most of the work needed to containerize nfsd.
> 
>> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com




