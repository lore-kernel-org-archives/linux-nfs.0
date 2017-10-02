Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:55021 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751268AbdJBT3O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Oct 2017 15:29:14 -0400
Received: by mail-vk0-f52.google.com with SMTP id c19so3427468vke.11
        for <linux-nfs@vger.kernel.org>; Mon, 02 Oct 2017 12:29:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87wpo9lydp.fsf@notabene.neil.brown.name>
References: <56BFE55D.1010509@wiktel.com> <87twjjpcl8.fsf@notabene.neil.brown.name>
 <57062C53.9080102@wiktel.com> <87wpo9lydp.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 2 Oct 2017 15:29:13 -0400
Message-ID: <CAN-5tyG7BeAoy_tqap23CM8rCHcyOcy2Jee3us+xU4kxVV54gA@mail.gmail.com>
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: NeilBrown <nfbrown@novell.com>
Cc: Richard Laager <rlaager@wiktel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

Was your patch 3ffbc1d6558 (net/sunrpc/xprt_sock: fix regression in
connection error reporting) is an attempt to fix this problem or was
it  something else (latter is what I think but would like to verify)?

I was wondering if there was anything done upstream that fixed this issue.


On Thu, Apr 7, 2016 at 8:47 PM, NeilBrown <nfbrown@novell.com> wrote:
> On Thu, Apr 07 2016, Richard Laager wrote:
>
>>
>> In a separate failover event, I tested accessing NFS over TCP. I do
>> *not* get "Received RST segment.". So I conclude that
>> tcp_validate_incoming() is not being called.
>
> Thanks for all the details.  The ssh experiment quite convincingly shows
> that the network infrastructure is working correctly.
>
> The NFS experiment is strange - the RST doesn't even seem to be
> arriving.  Yet the tcpdump shows that it did.
>
>>
>> Any thoughts on what that means or where to go from here?
>
> Working back from tcp_validate_incoming, it is called from two places.
> One is tcp_rcv_state_process() which handles connections which are not
> currently established, so it should be irrelevant.
> The other is tcp_rcv_stablished().
> As the RST flag is set the fast-path branch will not be taken (as
> ->pred_flags cannot possibly contain RST) so it should reach the
> slow_path: label.  The only things that can stop the code reaching
> tcp_validate_incoming() is the "len" being less than 20 (which it isn't)
> or the tcp checksum being wrong.
> The tcpdump showed the checksum as '0', but that could be due to tcp
> checksum offload.
>
> You could add some printks in there (After slow_path:) to report when
> tcp_checksum_complete_user() fails, particularly for th->rst packets.
>
> Or you could try turning off tcp checksum offloading with
>   ethtool  --offload rx off DEVICENAME
> (I think).
>
> It might help to see a tcpdump trace of the case where the "ssh"
> connection was broken successfully for comparison with the case where
> the nfs connection wasn't broken.  Or it might not.
>
> NeilBrown
