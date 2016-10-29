Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:34972 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753024AbcJ2WKl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2016 18:10:41 -0400
Received: by mail-ua0-f182.google.com with SMTP id 12so79765037uas.2
        for <linux-nfs@vger.kernel.org>; Sat, 29 Oct 2016 15:10:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHc6FU5i3aDDNUKLUot9B8hjbiMxFR4nipB3b-ROa9k4a6KhPQ@mail.gmail.com>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com> <CAHc6FU5i3aDDNUKLUot9B8hjbiMxFR4nipB3b-ROa9k4a6KhPQ@mail.gmail.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Sun, 30 Oct 2016 00:10:39 +0200
Message-ID: <CAHc6FU7Y9rAqkZnAO9hHHu1Dqm4=KhkeecbE4tH0vuw_1PUz2A@mail.gmail.com>
Subject: Re: [PATCH 0/2] NFSv4.2 umask support
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2016 at 11:38 AM, Andreas Gruenbacher
<agruenba@redhat.com> wrote:
> On Fri, Oct 28, 2016 at 10:23 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>> From: "J. Bruce Fields" <bfields@redhat.com>
>>
>> The following patches allow the umask to be ignored in the presence of
>> inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
>> mostly useless whenever the umask masks out group bits.
>>
>> This solves a problem we've seen complaints about for some time, both
>> upstream and from RHEL users.
>>
>> The new protocol has been discussed in the IETF working group and is
>> documented at:
>>
>>         https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02
>>
>> It's unlikely that we'll discover problems requiring an incompatible
>> change, so I think we should consider this for 4.10.
>
> Nope, these patches don't implement draft-ietf-nfsv4-umask-02 yet, and
> need updating first.

Oops, turns out I was confused. The patches do implement the proposed
new mode_umask attribute right but call it FATTR4_WORD2_UMASK in the
code, which doesn't seem right. Let me follow up with a version that
renames the attribute to FATTR4_WORD2_MODE_UMASK. The rest looks fine.

Thanks,
Andreas
