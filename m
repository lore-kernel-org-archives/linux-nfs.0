Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:45672 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923Ab2JQBgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Oct 2012 21:36:49 -0400
Message-ID: <507E0BF0.7050207@asianux.com>
Date: Wed, 17 Oct 2012 09:37:52 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
References: <507B70F1.7040903@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com> <507B968A.9090104@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA90923F1C4@SACEXCMBX04-PRD.hq.netapp.com> <507CBA3F.6000204@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909253103@SACEXCMBX04-PRD.hq.netapp.com> <507CDEF2.2060809@asianux.com> <20121016063348.7b225bfb@tlielax.poochiereds.net> <507D48A6.3070601@asianux.com> <20121016081320.74fccc5b@tlielax.poochiereds.net>
In-Reply-To: <20121016081320.74fccc5b@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012年10月16日 20:13, Jeff Layton 写道:
>>
>> 2) but, are we truly no ways to solve this issue ?  (I do not think so).
>>
> 
> Not that I see, but don't let me stop you from trying to find one. ;)
> 

we can divide the issue to 2 separate parts:

1) the inconsistent attribute by time delay between client and server:

   A) it is the nfs v2/v3 design issue, the "user" can understand (not
implementation mistake)
   B) we need make the time delay as shorter as we can. (this is the
reason why I call it "performance", although this "word" is still not
quit suitable)
   C) "user" can understand, not mean can bear (such as skipping writing
operation attribute changes)

2) the inconsistent attribute by a client itself:

   A) it is implementation issue, the "user" can not understand (it is
an implementation mistake)
   B) we need solve it (so I call it "correctness" issue).
   C) "user" can not understand, not mean can not bear (such as current
issue which I report)

at last, for maintainer:
   A) for "performance", we need try our best to do;
   B) for "correctness", we need fix it completely;

>> 3) I think an executable way (but maybe not a good way) is :
>>
>>    A) for each client, check each task id of the client its own (such as
>> rpc task xid), so can know the order of tasks of the client its own.
>>
> 
> We do something like this already. That's what the gencount thing is
> all about. It's still possible though to fool that check if two calls
> are scheduled closely enough.
>

1) I think gencount is not equal to sequence number, the sequence number
can mark all relative tasks of one client in order.

2) I also think, it is not quite complex to make a client itself in
consistency. (it is implementation issue, not design issue)


> Also note that it's not just the reordering of replies that you have to
> concern yourself with. The requests themselves can be reordered on the
> network. The server is also under no obligation to execute calls in the
> order received.
> 

1) I agree with you, in nfs_inode_attrs_need_update(), it need consider
this situation (the tasks from server return is not in order).

2) I do not think it can not be accomplished if the tasks of client
itself have sequence number.  (maybe, it would be enough to only judge
which task is later between the 2 tasks by sequence number).


>>    B) maybe also need another some synchronization code, but I think it
>> does not have much negative effect with performance.
>>
> 
> Yeah, serializing things to fix this is probably a non-starter. NFSv2
> and UDP transports are basically legacy code at this point, so there's
> not a lot of incentive to do anything drastic here.
> 

1) I agree with what you said above, but maybe you misunderstand of what
I said for the "item B)"

2) the "item B)" is for the completion of "item A)". when we fix this
issue, maybe have to add additional synchronization code which maybe can
cause negative effect with performance, but I think it is not much
("user" can bear).

At last, I suggest we need think of how to fix this implementation bug
in nfs-client region.

-- 
Chen Gang

Asianux Corporation
