Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:37485 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168AbaE1O1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:27:15 -0400
Received: by mail-qg0-f52.google.com with SMTP id a108so18220072qge.11
        for <linux-nfs@vger.kernel.org>; Wed, 28 May 2014 07:27:14 -0700 (PDT)
Message-ID: <5385F239.30007@gmail.com>
Date: Wed, 28 May 2014 10:27:05 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
References: <1400787148-25941-1-git-send-email-bfields@redhat.com> <1400787148-25941-42-git-send-email-bfields@redhat.com> <20140528080945.GA6797@infradead.org> <20140528140151.GB13012@pad.redhat.com> <5385EEF5.9050904@gmail.com> <20140528142320.GC13012@pad.redhat.com>
In-Reply-To: <20140528142320.GC13012@pad.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/28/2014 10:23 AM, J. Bruce Fields wrote:
> On Wed, May 28, 2014 at 10:13:09AM -0400, Anna Schumaker wrote:
>> On 05/28/2014 10:01 AM, J. Bruce Fields wrote:
>>> On Wed, May 28, 2014 at 01:09:45AM -0700, Christoph Hellwig wrote:
>>>> On Thu, May 22, 2014 at 03:32:16PM -0400, J. Bruce Fields wrote:
>>>>> Later patches handle those "exotic compounds", this one just makes
>>>>> sure zero-copy is turned off in those cases.
>>>> How did you test these exotic compounds?
>>> I have is a pynfs test that sends a compound with multiple reads in
>>> it.
>>>
>>> I don't think that's pushed out to my regular pynfs tree, I'll try
>>> to do that today.
>>>
>>> I could really use more of those.  Maybe I'm wrong, but I'm worried
>>> less about this case than the more finicky out-of-reply-space cases,
>>> where I do have patches puporting to fix problems that I haven't
>>> really verified.
>> I'll eventually be using this case for READ_PLUS.  I'll be sure to
>> send problems your way! :)
> Great, thanks.
>
> Actually my main question there is how to handle 4.2 in pynfs.
>
> 4.1 and 4.0 are entirely separate codebases.  We definitely don't want
> to do that again.

Can you make v4.2 a new file that uses the v4.1 functions?  That way all the v4.2 stuff is kept together.  I want to try doing something similar on the client for functions in nfs4proc.c and nfs4xdr.c.

Anna
>
> There's not much point re-running all the 4.1 tests over 4.2.  Maybe all
> we may need is to say "use minor version 2 on this compound" in tests of
> the new features.
>
> But I haven't even tried to figure out how to tell pynfs about the new
> .x files.
>
> --b.

