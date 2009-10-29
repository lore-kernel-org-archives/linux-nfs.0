From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than a protoname
Date: Thu, 29 Oct 2009 13:51:09 -0400
Message-ID: <75656B48-F96B-4745-8665-5ACAB5CB3530@oracle.com>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com> <9EF4B3B4-5F00-4E66-81AA-ADDF348ADED4@oracle.com> <20091028184106.019ccbc6@tlielax.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:58954 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbZJ2Rvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Oct 2009 13:51:35 -0400
In-Reply-To: <20091028184106.019ccbc6-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 28, 2009, at 6:41 PM, Jeff Layton wrote:
> On Wed, 28 Oct 2009 16:15:33 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>>
>>> /*
>>> @@ -578,7 +609,7 @@ static void nfs_show_mount_options(struct
>>> seq_file *m, struct nfs_server *nfss,
>>> 			seq_puts(m, nfs_infop->nostr);
>>> 	}
>>> 	seq_printf(m, ",proto=%s",
>>> -		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_PROTO));
>>> +		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));
>>
>> Does that do the right thing for rdma mounts, currently?
>>
>
> Unfortunately, I don't have an easy way to test this with RDMA yet,  
> but
> it looks like it'll do the right thing. The RPC_DISPLAY_PROTO and
> RPC_DISPLAY_NETID strings both get set to "rdma".
>
> As best I can tell IPv6 support for RDMA doesn't exist yet, so that
> seems to be the right thing to do for now.

OK... the NFS client plays some games with the internal protocol  
settings to get NLM and MNT to go over TCP instead of RDMA.  I guess  
the PROTO and NETID strings are still "rdma" in this case, but it's  
worth keeping an eye on.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



