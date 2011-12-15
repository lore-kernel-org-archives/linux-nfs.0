Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44183 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759004Ab1LORU6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 12:20:58 -0500
Message-ID: <4EEA2BF7.5030107@gmail.com>
Date: Thu, 15 Dec 2011 12:18:47 -0500
From: Ric Wheeler <ricwheeler@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "Loke, Chetan" <Chetan.Loke@netscout.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-scsi@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
References: <4EE8F75F.6070800@gmail.com>  <20111214192739.GN2203@ZenIV.linux.org.uk> <4EE8FC2E.3010207@gmail.com>  <20111214222723.GD7623@fieldses.org>  <1323961140.14317.2.camel@lade.trondhjem.org>  <D3F292ADF945FB49B35E96C94C2061B91516E391@nsmail.netscout.com>  <1323965498.14317.13.camel@lade.trondhjem.org>  <D3F292ADF945FB49B35E96C94C2061B91516E3FC@nsmail.netscout.com> <1323968015.14317.28.camel@lade.trondhjem.org>
In-Reply-To: <1323968015.14317.28.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/15/2011 11:53 AM, Trond Myklebust wrote:
> On Thu, 2011-12-15 at 11:40 -0500, Loke, Chetan wrote:
>>>> Why not support something like the async-iocb?
>>> You could, but that would tie copyfile() to the aio interface which was
>>> one of the things that I believe Al was opposed to when we discussed
>>> this at LSF/MM-2010.
>>>
>> virtualization vendors who support this offload do it at a layer above the guest-OS(Intra-LUN(tm) locking or whatever fancy locking). So I think 'copyfile' is going to be appealing to application-developers more than the hypervisor-vendors.
> The application is thin provisioning, not the 'cp' command. When
> virtualisation vendors do support this, it will mainly be as part of
> their image management toolkits, not the hypervisor.

I think that hypervisor vendors will be very interested in this feature which 
would explain why vmware was active in drafting both the NFS and T10 specs. Not 
to mention those of us who use KVM or XEN :)

As Trond mentions, we might have this in the management tool chain or other 
places in the stack.

>
>> So let's think about it from end-users perspective:
>> Won't everyone replicate code to check - 'Am I done'? It will just make application folks write more (ugly)code. Because you would then have to maintain another queue/etc to check for this operation.
> 'Am I done' is easy: copyfile() returns with the number of bytes that
> have been copied.
>
> 'Is my copyfile() syscall making progress' is the question that needs
> answering.
>
>> We can just support full-copy. Partial copies can be returned as failure.
> Then you have to check the entire range on error instead of just
> resuming the copy from where it stopped.
>

I also like simple first. I am not too certain about the need for polling 
(especially given how little we have done historically to take advantage of the 
notifications, water marks, etc in things like thin provisioning :)).

On the other hand, I also don't object to having the ability to poll (through 
the ioctl or whatever) if others find that useful.

What I would like to see is a way to make sure that we can interrupt any long 
running command & also make sure that our timeouts (for SCSI specifically) are 
not too aggressive.

Ric


