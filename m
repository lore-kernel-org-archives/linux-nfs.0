Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.wiktel.com ([69.89.207.151]:33554 "EHLO smtp1.wiktel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750927AbdJCAJy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Oct 2017 20:09:54 -0400
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: Olga Kornievskaia <aglo@umich.edu>
Cc: NeilBrown <nfbrown@novell.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <56BFE55D.1010509@wiktel.com>
 <87twjjpcl8.fsf@notabene.neil.brown.name> <57062C53.9080102@wiktel.com>
 <87wpo9lydp.fsf@notabene.neil.brown.name>
 <CAN-5tyHuuBJxwqFLkiZa5ktBk7ypCJxmZ9creeD_RGWbK4Xn3A@mail.gmail.com>
 <f253a98b-2f18-36ae-31a7-ce3911d798ff@wiktel.com>
 <CAN-5tyGc6jdJgSNio85wWXP1jEzjGmofmxpo3XhC9G+xc_NJPQ@mail.gmail.com>
From: Richard Laager <rlaager@wiktel.com>
Message-ID: <20de1b7e-efca-e2e1-e9e0-e9aff5a1a1af@wiktel.com>
Date: Mon, 2 Oct 2017 19:09:53 -0500
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGc6jdJgSNio85wWXP1jEzjGmofmxpo3XhC9G+xc_NJPQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/02/2017 05:03 PM, Olga Kornievskaia wrote:
> On Mon, Oct 2, 2017 at 3:48 PM, Richard Laager <rlaager@wiktel.com> wrote:
>> On 10/02/2017 02:45 PM, Olga Kornievskaia wrote:
>>> Did turning off tcp checksum offloading take care of the problem by any chance?
>>
>> I don't think so, but I'm not 100% sure. I keep meaning to get back to
>> working on this, but since UDP is working and it's somewhat disruptive
>> to test, I haven't.
> 
> From the network trace that you've provided shouldn't SEQ# should have
> been 545 instead of 465. If server is sending wrong values in the RST
> then client would drop it?

I don't know enough about TCP to be sure. But the RST has Ack: 465. I
think that's normal?

-- 
Richard
