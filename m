Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:33670 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdBTVbH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2017 16:31:07 -0500
Received: by mail-ua0-f170.google.com with SMTP id k1so14147935uab.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2017 13:31:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170220171519.GE12335@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-7-git-send-email-bfields@redhat.com> <1D136924-2EC7-4CF3-8250-98799DFBEB3F@oracle.com>
 <20170220160940.GB12335@parsley.fieldses.org> <4824B968-4ED6-44AA-A935-3D309D76EFFF@oracle.com>
 <20170220171519.GE12335@parsley.fieldses.org>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Mon, 20 Feb 2017 22:31:00 +0100
Message-ID: <CAHc6FU6_bJE--6Da5Df+g+qRj6C1KZUL5PvkXrZ-mKbJqU936w@mail.gmail.com>
Subject: Re: [PATCH 6/6] NFSv4: allow getacl rpc to allocate pages on demand
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dros Adamson <dros@primarydata.com>,
        Weston Andros Adamson <dros@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 20, 2017 at 6:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Mon, Feb 20, 2017 at 11:42:31AM -0500, Chuck Lever wrote:
>>
>> > On Feb 20, 2017, at 11:09 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>> >
>> > On Sun, Feb 19, 2017 at 02:29:03PM -0500, Chuck Lever wrote:
>> >>
>> >>> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> >>>
>> >>> From: Weston Andros Adamson <dros@netapp.com>
>> >>>
>> >>> Instead of preallocating pags, allow xdr_partial_copy_from_skb() to
>> >>> allocate whatever pages we need on demand.  This is what the NFSv3 ACL
>> >>> code does.
>> >>
>> >> The patch description does not explain why this change is
>> >> being done.
>> >
>> > The only justification I see is avoiding allocating pages unnecessarily.
>>
>> That makes sense. Is there a real world workload that has seen
>> a negative effect?
>>
>>
>> > Without this patch, for each getacl, we allocate 17 pages (if I'm
>> > calculating correctly) and probably rarely use most of them.
>> >
>> > In the v3 case I think it's 7 pages instead of 17.
>>
>> I would have guessed 9. Out of curiosity, is there a reason
>> documented for these size limits?
>
>
> In the v4 case:
>
>         #define NFS4ACL_MAXPAGES DIV_ROUND_UP(XATTR_SIZE_MAX, PAGE_SIZE)
>
> And I believe XATTR_SIZE_MAX is a global maximum on the size of any
> extend attribute value.

XATTR_SIZE_MAX is the maximum size of an extended attribute. NFSv4
ACLs are passed through unchanged in "system.nfs4_acl".

> In the v3 case:
>
>         /* Maximum number of ACL entries over NFS */
>         #define NFS_ACL_MAX_ENTRIES     1024
>
>         #define NFSACL_MAXPAGES         ((2*(8+12*NFS_ACL_MAX_ENTRIES) + PAGE_SIZE-1) \
>                                          >> PAGE_SHIFT)
>
> No idea where that 1024 comes from.

The 1024-entry limit is arbitrary.

Andreas
