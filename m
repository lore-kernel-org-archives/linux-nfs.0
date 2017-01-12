Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:33403 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750889AbdALP3P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 10:29:15 -0500
Received: by mail-qt0-f177.google.com with SMTP id v23so21020309qtb.0
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 07:29:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170112021703.GC18977@fieldses.org>
References: <20170104165636.GA17649@fieldses.org> <20170112021703.GC18977@fieldses.org>
From: Andy Adamson <androsadamson@gmail.com>
Date: Thu, 12 Jan 2017 10:29:14 -0500
Message-ID: <CAHVgHyWeGj4GGap8axPnaJYAOBup=LXdeVdQ3fz1o6q7JWkT_w@mail.gmail.com>
Subject: Re: RFC: make labeled NFS opt-in
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS list <linux-nfs@vger.kernel.org>, tibbs@math.uh.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

HI Bruce

NFSv4.2 labeled NFS provides 'guest mode' Mandatory Access Control
(MAC) where the client can enforce labeling and store a label on the
server, but the server itself does not enforce the same MAC as the
client because the client request thread label is unknown to the
server. RPCSEC_GSS version 3 label assertions asserts the client
thread label on the NFSD thread handling the request, and so along
with LNFS provides Full Mode MAC.

AFAICS the only time we want GSS3 label assertions is if LNFS is
enabled.  Does this sound right to you? If so, I will use this new per
export LNFS option to determine when GSS3 label assertions are
enabled.

-->Andy

On Wed, Jan 11, 2017 at 9:17 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Jan 04, 2017 at 11:56:36AM -0500, bfields wrote:
>> This is something I should have noticed before merging labeled NFS:
>> labeled NFS shouldn't be on by default, among other reasons because it
>> assumes everybody's using consistent security policies.  As 4.2 is
>> getting turned on by default, this is starting to generate bug reports.
>>
>> The patch below turns it off by default, and provides a new option to
>> turn it on per export.  The drawback is a regression on kernel upgrade
>> for anyone depending on labeled NFS, until they find the new option.  My
>> impression is that's a specialized use case that still has a small
>> number of users at this point, so I think we can get away with that.
>>
>> The below is untested.  I have a (small) nfs-utils patch as well.
>
> OK, I've tested now, the only problem was actually a preexisting
> bug--I'll post the patches, plus the companion nfs-utils patch.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
