Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:38866 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750756AbeDXU3Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2018 16:29:16 -0400
Received: by mail-vk0-f48.google.com with SMTP id b16so12500432vka.5
        for <linux-nfs@vger.kernel.org>; Tue, 24 Apr 2018 13:29:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180418070842.GC8764@infradead.org>
References: <20180413170158.17589-1-kolga@netapp.com> <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org> <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <1b45673f-516d-51ff-a1ef-8b07b9dd8619@RedHat.com> <1E0C45FE-2214-41FB-8634-1005CC13AD9E@netapp.com>
 <20180418070842.GC8764@infradead.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 24 Apr 2018 16:29:14 -0400
Message-ID: <CAN-5tyGVc5myRVrnS0vc3gKq5NbhhrkVVDuLZPn2XxXoO-=T8A@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <SteveD@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 18, 2018 at 3:08 AM, Christoph Hellwig <hch@infradead.org> wrot=
e:
> On Tue, Apr 17, 2018 at 11:19:25AM -0400, Olga Kornievskaia wrote:
>> Yes I agree. Let=E2=80=99s please decide if this will go in (with whatev=
er code improvements are required) or let=E2=80=99s drop it.
>
> Well, my vote is very clearly to drop it.

Bruce, when will you make a decision about this? Is there something
more that needs to happen before it can be decided if the "async"
patches are moving forward (and then "inter" patches).
