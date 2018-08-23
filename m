Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f67.google.com ([209.85.222.67]:47039 "EHLO
        mail-ua1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726780AbeHWWCJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2018 18:02:09 -0400
Received: by mail-ua1-f67.google.com with SMTP id u11-v6so3807403uan.13
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2018 11:31:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180720221925.50744-1-kolga@netapp.com> <20180809203450.GE14104@parsley.fieldses.org>
 <20180823014722.GA24441@fieldses.org> <20180823122231.GA32415@fieldses.org> <20180823123216.GB32415@fieldses.org>
In-Reply-To: <20180823123216.GB32415@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 23 Aug 2018 14:30:59 -0400
Message-ID: <CAN-5tyGBov4SZJbG1Gs6_Ujtwc_2g15VR5ZY0y2bXUdb=cwOhQ@mail.gmail.com>
Subject: Re: [PATCH v10 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 23, 2018 at 12:18 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Aug 23, 2018 at 08:22:31AM -0400, J. Bruce Fields wrote:
> > On Wed, Aug 22, 2018 at 09:47:22PM -0400, bfields wrote:
> > > Results are in my linux-next branch.
>
> Actually, make that
>
>         git:///linux-nfs.org/~bfields/linux.git for-4.20-incoming

Ok I'll take a look. I'll work on "inter" copy on top of that.
