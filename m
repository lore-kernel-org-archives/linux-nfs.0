Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f170.google.com ([209.85.215.170]:65317 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab3JBGCv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 02:02:51 -0400
Received: by mail-ea0-f170.google.com with SMTP id h14so137511eak.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Oct 2013 23:02:50 -0700 (PDT)
Message-ID: <524BB707.20609@primarydata.com>
Date: Wed, 02 Oct 2013 09:02:47 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Lev Solomonov <solo@primarydata.com>,
        Idan Kedar <idank@primarydata.com>,
        Nadav Shemer <nadav@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH RFC v0 0/49] pnfsd-dlm
References: <52447EA0.7070004@primarydata.com> <524588C7.9040500@panasas.com> <CAEMWVhsD-f2wZJzASMtC10XHPH2aSTzVLtYje3U8ezP_+67rWw@mail.gmail.com> <5245B44B.2080508@panasas.com> <CAEMWVhtE9TTB4i4iidfayVwWWX5aTtQ7pnKXPfba3YUZ2fapfg@mail.gmail.com> <524A161D.50408@panasas.com>
In-Reply-To: <524A161D.50408@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-01 03:23, Boaz Harrosh wrote:
> On 09/27/2013 01:19 PM, Benny Halevy wrote:> On Fri, Sep 27, 2013 at 12:37 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>> Boaz, sorry but the files layout went first to production on the
>> client side in all major
>> enterprise distributions so it doesn't make sense to submit exofs first.
>> As for your patch series, I respect the work you did on it but
>> a. as you said it is your patch series, not mine
> 
> This is not my patch series it is all of ours patch series I do
> not have a different one then yours. Every one did some work
> in his area. So I wrote the exofs part as well as lots of core
> parts. But we always kept one tree. Our tree
> 
>> b. the forward port from 3.10 on changed the layout state handling
>> radically (for the better I hope :)
>> solving numerous correctness issues.
> 
> Cool good is good, right? Do you mean that exofs would not work now.
> Why would it be broken?

No, it should work in principle.
The main change is moving the recall cookie from the layout return
interface to a new call: "layout_recall_done".

> 
>> The motivation behind the dlm based implementation is to have a
>> minimal useful pnfs implementation
>> that folks can use and test the client against.
> 
> What kind of dumb test is DLM, without any write support. It is
> plain not pNFS it is a freak. There is nothing to test. READONLY
> file system, don't you see the joke in that?

It is what it is now and it can be improved.

> 
> If this is your motivation, testing, then at least put pnfs-exp
> as the reference implementation for some real client testing.
> 

It is possible, but maybe borrowing some functionality from pnfsd-lexp
such as layout segments, io error injection, controlling layoutcommit-through-mds,
or return on close, might be helpful

>> On this basis, writes layout can be added,
> 
> What writes layout in DLM? no hands waving please.
> 

Write layouts can be used for load balancing with affinity.
For example, if someone holds an exclusive lock on the file
point to that node, otherwise pick ino % #nodes.

>> and further on, exofs
>> support can submitted as the next stage.
>>
> 
> You are doing the work, what can I say. We have decided this before
> I think it was even Bruce's idea not mine. So you change that decision?

It's based on reconsidered according to the current state of upstream
and the patchset, but my goal is to submit both, just in stages, one on top of the other.

> 
> For me the DLM is a joke and a bad face for the 6 years of effort
> I put on this thing.

I agree that besides being a basic testing tool and a basis for further
improvement it's a methodological stage at this point, I'm ok if it's
useful even for simplifying the review process.

> This is not pNFS and will do more arm then good
> to my cause. If you need it just for testing why do you need it in
> mainline? mainline is for real users and benefits no?

The value for users is currently improving read only bandwidth.
Again, not ideal, but a good start.

>  
> I think I agree with Christoph Better wait for a real open-source
> pNFS server implementation before putting any of this in the Kernel.

There's a chicken and egg problem here.
I'm absolutely ok with reviewing the patchset piece wise and submitting exofs
in one shot.  There is an opportunity to submit just the pnfsd-dlm part
that is self contained to put a stake in the ground early on.
This is essentially up to Bruce to decide what he takes in first.

> Just leave it out-of-tree as it is now. The only real open-source
> pNFS server implementation out there today that can demonstrate 10G
> saturation and scalability of up to 40G in the 40 nodes setup I had, is exofs.
> So it is the only one that can justify such a big piece added to the Kernel.
> Real sorry for the inconvenience of it being objects and not files.
> If it would matter to someone so much as it did for me then perhaps
> he would sit on his "thing" and implement one. But the fact is that no
> one cares for a files-layout open-source server.
> 
> And you are off the hook this is the last I will comment on this.

Boaz, it does not have to be, and should not be a flame war.
Feel free to discuss and try to convince, just please, I just can't hear you
if you shout...

> 
>> Benny
>>
> 
> Thanks
> Boaz
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
