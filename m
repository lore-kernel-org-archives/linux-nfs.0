Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35803 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdATPtK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jan 2017 10:49:10 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so3322848ith.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jan 2017 07:49:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <8C661DEF-5BD9-46F4-AD68-E68C3FF720C1@netapp.com>
References: <1459541983-21301-1-git-send-email-kolga@netapp.com>
 <CAN-5tyG6-TPbBxmMYpLPv6_duwAYRm1V_QtRSWepT6un5EtNAg@mail.gmail.com>
 <D828C666-FE77-4E43-925B-A6A4FC647E50@primarydata.com> <06CF6532-70AD-428F-93C7-C30305E09B35@netapp.com>
 <89D056A4-F0C2-4DDF-9637-731A88355A9F@primarydata.com> <DAAF9132-C732-427E-88F0-321679D07750@netapp.com>
 <B4620365-C09B-4E12-8B3A-C5AD922AD773@primarydata.com> <8C661DEF-5BD9-46F4-AD68-E68C3FF720C1@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 20 Jan 2017 10:41:26 -0500
Message-ID: <CAN-5tyHrZUx1M+mPzvMnP4Jah5yBFsumCQbHub+R1+++puTGdA@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv3: Ignore wcc before ctime attribute
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2017 at 11:38 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
>
> On Jan 17, 2017, at 11:36 AM, Trond Myklebust <trondmy@primarydata.com>
> wrote:
>
>
> On Jan 17, 2017, at 11:34, Olga Kornievskaia <kolga@netapp.com> wrote:
>
>
> On Jan 17, 2017, at 11:23 AM, Trond Myklebust <trondmy@primarydata.com>
> wrote:
>
> ca0daa277aca
>
>
> The problem is on v3 is this patch suppose to help ?
>
>
> It is protocol agnostic.
>
>
> Ok, I will test !

My testing shows no invalidations with the patch where prior to that
it would do so. Thanks Trond.
