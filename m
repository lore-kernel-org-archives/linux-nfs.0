Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:40824 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752145AbeDQOIS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 10:08:18 -0400
Received: by mail-vk0-f46.google.com with SMTP id x204so11850732vkd.7
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 07:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180417135708.GD10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com> <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org> <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <20180417134141.GB10291@parsley.fieldses.org> <FE7DF381-A335-4827-94AB-1DEBF5FCEB05@netapp.com>
 <20180417135708.GD10291@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 17 Apr 2018 10:08:15 -0400
Message-ID: <CAN-5tyFf2dkQYhbeULgKMuN8i=hJ4JUnETwN6x0J786H_fWVLg@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Jorge Mora <Jorge.Mora@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2018 at 9:57 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> On Tue, Apr 17, 2018 at 09:43:45AM -0400, Olga Kornievskaia wrote:
>> > On Apr 17, 2018, at 9:41 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>> > Christoph said: "I'd like to see numbers for actual, real use cases."
>> > Yes, I'd love to see that too.
>> >
>> > Is it possible to get testing on real hardware that we'd expect people
>> > to use, with sufficient details about the setup that someone else could
>> > reproduce the results?
>>
>> The numbers we presented was on real hardware. If you have any more questions regarding the setup please ask.
>
> Argh, sorry, you had to remind me once already:
>
>         https://www.ietf.org/mail-archive/web/nfsv4/current/msg15379.html

Yes that was for the "inter" copy.

Besides those numbers, Jorge also did the numbers for the asynchronous
vs synchronous intra copy. Are you interested in them as well?
Hopefully Jorge still has them.
