Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20208 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326Ab2BOSpl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 13:45:41 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andy Adamson <androsadamson@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
Date: Wed, 15 Feb 2012 18:45:35 +0000
Message-ID: <A386FAEF-33D5-470F-8D52-08A58AF7AF1F@netapp.com>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1329259606.11759.15.camel@lade.trondhjem.org>
 <4F3AFD84.3020709@nexenta.com> <1329266587.28837.4.camel@lade.trondhjem.org>
 <20120215005315.GA9018@fieldses.org>
 <1329270628.28837.15.camel@lade.trondhjem.org>
 <1329273001.28837.19.camel@lade.trondhjem.org>
 <077E41FB-D306-45F5-9344-05A15330A483@netapp.com>
 <1329320764.3364.19.camel@lade.trondhjem.org>
 <CAHVgHyVAeBdJaMpFj5cxKpntmL+vGs8-JNiyQ=tzcJj4Y53jvA@mail.gmail.com>
 <1329331059.3364.41.camel@lade.trondhjem.org>
In-Reply-To: <1329331059.3364.41.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2012, at 1:37 PM, Myklebust, Trond wrote:

> On Wed, 2012-02-15 at 11:06 -0500, Andy Adamson wrote:
>> On Wed, Feb 15, 2012 at 10:46 AM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Wed, 2012-02-15 at 15:07 +0000, Adamson, Andy wrote:
>>>> 
>>>> Please don't merge nfs4_reset_slot_tables and nfs4_init_slot_tables.  It  assumes a static array (realloc) which goes away with the dynamic slot table code. Instead, take a look at the patch set I sent on Feb 12
>>> 
>>> Why not? There is _no_ functional difference between what
>>> nfs4_reset_slot_tables() and nfs4_init_slot_tables() need to do.
>>> They both need to allocate new slots (conditionally in the case of
>>> nfs4_reset_slot_tables, but the condition is compatible with the
>>> nfs4_init_slot_tables case), and they both need to initialise those
>>> slots to the value '1'.
>> 
>> The reset case also needs to reduce the number of slots.  In the
>> dynamic slot case, the reset function will not require draining of the
>> session. So reset will, in response to a change in  the
>> target_highest_slotid or a CB_RECALL_SLOT from the server, add or
>> remove slots without draining the session. In this case, reset will
>> only initialize any new slots sequence numbers to 1, not all slots.
>> 
>> That said, I guess it can all be in one function.
>> 
>>> 
>>> AFAICS There is no reason for keeping those as 2 separate functions, and
>>> I don't see how the dynamic session patches change anything to that
>>> conclusion.
>>> 
>>>> [PATCH Version 7 3/3] NFSv4.1 avoid freeing slot when tasks are waiting
>>>> [PATCH Version 1 2/3] NFSv4.1 prepare for dyamic session slots
>>>> [PATCH Version 7 1/3] NFS4.1 clean up nfs4_alloc_session
>>> 
>>> I need a fix for the 3.3 final...
>>> 
>>> Those patches can be cleaned up and made ready for 3.4 (needs work -
>>> they won't apply to the 'nfs-for-next' branch),
>> 
>> I worked against the bugfix branch. I'll use the nfs-for-next branch.
>> 
>>> but right now they're
>>> not sufficiently tested nor are they sufficiently reviewed.
>> 
>> Agreed. I want to test some more at connectathon. I did iozone tests
>> to show that this dynamic slot implementation performs as well as the
>> static array, but not enough testing / review for coding bugs.
>> 
>>> For
>>> instance, I'm not happy with the idea of adding a 'tk_private' field in
>>> the struct rpc_task.
>> 
>> OK. Do you have a suggestion?
> 
> Yes. Please see how we solve the minor version 0 equivalent problem in
> nfs_release_seqid().
> 
> In the case of minor version 1, I suggest setting up a dedicated linked
> list of 'things waiting for a slot', where each entry in the linked list
> contains the nfs4_sequence_args/nfs4_sequence_res to initialise, and
> then a pointer to the rpc_task to wake up.

OK - thanks for the advice.

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

