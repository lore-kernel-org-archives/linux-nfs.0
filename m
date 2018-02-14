Return-Path: <olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Sender: olga.kornievskaia@gmail.com
In-Reply-To: <D0761437-4614-41C7-AC85-76EF45D67C70@redhat.com>
References: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
 <1479140396-17779-2-git-send-email-trond.myklebust@primarydata.com>
 <CAN-5tyGEn3vGJicR+00ATSp7PzUEm_6FzjBwYwiS-++OcqqfaA@mail.gmail.com>
 <698A2B0C-1E38-4B65-ABA3-60C396393E30@redhat.com> <1518621683.13566.5.camel@redhat.com>
 <1518622194.4737.1.camel@primarydata.com> <D0761437-4614-41C7-AC85-76EF45D67C70@redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 14 Feb 2018 11:06:24 -0500
Message-ID: <CAN-5tyH-nRRv3EM=APyShUs0ayzEWZN=8ND6ecfjXgag6XhWnQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix CLOSE races with OPEN
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trondmy@primarydata.com>, Jeff Layton <jlayton@redhat.com>,
	linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 14, 2018 at 10:42 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On 14 Feb 2018, at 10:29, Trond Myklebust wrote:
>> On Wed, 2018-02-14 at 10:21 -0500, Jeff Layton wrote:
>>> On Wed, 2018-02-14 at 10:05 -0500, Benjamin Coddington wrote:
>>>> Hi Olga,
>>>>
>>>> On 13 Feb 2018, at 15:08, Olga Kornievskaia wrote:
>>>>
>>>>> On Mon, Nov 14, 2016 at 11:19 AM, Trond Myklebust
>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>> ...
>>>> Ah, good question there..  Even though the stateid is not useful
>>>> for
>>>> operations that follow, I think the sequenceid should be
>>>> incremented because
>>>> the CLOSE is an operation that modifies the set of locks or state:
>>>>
>>>
>>> It doesn't matter.
>
> Yes, good condensed point.  It doesn't matter.
>
>>>> ...
>> Is there a proposal to change the current client behaviour here? As far
>> as I can tell, the answer is "no". Am I missing something?
>
> Not that I can see.  I think we're just comparing linux and netapp server
> behaviors..
>
> Ben

I just found very surprising that in nfs4_close_done() which calls
eventually calls nfs_clear_open_stateid_locked() we change the state
based on the stateid received from the CLOSE.
nfs_clear_open_stateid_locked() is only called from nfs4_close_done()
and no other function.

I guess I'm not wondering if we had this problem described in this
patch of the delayed CLOSE, if we didn't update the state after
receiving the close... (so yes this is a weak proposal).
