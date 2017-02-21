Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:33359 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751438AbdBUVVG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2017 16:21:06 -0500
Received: by mail-ua0-f174.google.com with SMTP id h65so13724703uah.0
        for <linux-nfs@vger.kernel.org>; Tue, 21 Feb 2017 13:21:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E06C6589-2E66-4013-9722-0FEADE596F70@oracle.com>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-7-git-send-email-bfields@redhat.com> <1D136924-2EC7-4CF3-8250-98799DFBEB3F@oracle.com>
 <20170220160940.GB12335@parsley.fieldses.org> <4824B968-4ED6-44AA-A935-3D309D76EFFF@oracle.com>
 <20170220171519.GE12335@parsley.fieldses.org> <CAHc6FU6_bJE--6Da5Df+g+qRj6C1KZUL5PvkXrZ-mKbJqU936w@mail.gmail.com>
 <E06C6589-2E66-4013-9722-0FEADE596F70@oracle.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Tue, 21 Feb 2017 22:21:05 +0100
Message-ID: <CAHc6FU6JghZAxiwj0XF0sOj1OufbxvabX+gYO52ROSZXDY1+dA@mail.gmail.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 21, 2017 at 7:46 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Andreas-
>
>
>> On Feb 20, 2017, at 4:31 PM, Andreas Gruenbacher <agruenba@redhat.com> wrote:
>>
>> On Mon, Feb 20, 2017 at 6:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> On Mon, Feb 20, 2017 at 11:42:31AM -0500, Chuck Lever wrote:
>>>>
>>>>> On Feb 20, 2017, at 11:09 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>>>>>
>>>>> On Sun, Feb 19, 2017 at 02:29:03PM -0500, Chuck Lever wrote:
>>>>>>
>>>>>>> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>>>>>>
>>>>>>> From: Weston Andros Adamson <dros@netapp.com>
>>>>>>>
>>>>>>> Instead of preallocating pags, allow xdr_partial_copy_from_skb() to
>>>>>>> allocate whatever pages we need on demand.  This is what the NFSv3 ACL
>>>>>>> code does.
>>>>>>
>>>>>> The patch description does not explain why this change is
>>>>>> being done.
>>>>>
>>>>> The only justification I see is avoiding allocating pages unnecessarily.
>>>>
>>>> That makes sense. Is there a real world workload that has seen
>>>> a negative effect?
>>>>
>>>>
>>>>> Without this patch, for each getacl, we allocate 17 pages (if I'm
>>>>> calculating correctly) and probably rarely use most of them.
>>>>>
>>>>> In the v3 case I think it's 7 pages instead of 17.
>>>>
>>>> I would have guessed 9. Out of curiosity, is there a reason
>>>> documented for these size limits?
>>>
>>>
>>> In the v4 case:
>>>
>>>        #define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
>>>
>>> And I believe XATTR_SIZE_MAX is a global maximum on the size of any
>>> extend attribute value.
>>
>> XATTR_SIZE_MAX is the maximum size of an extended attribute. NFSv4
>> ACLs are passed through unchanged in "system.nfs4_acl".
>
> "Extended attribute" means this is a Linux-specific limit?

Yes.

> Is there anything that prevents a non-Linux system from constructing
> or returning an ACL that is larger than that?

No.

> What happens on a Linux client when a server returns an ACL that does
> not fit in this allotment?

I would hope an error, but I haven't tested it.

Andreas
