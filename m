Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:65382 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbaFCESi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 00:18:38 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so4296435igd.8
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2014 21:18:37 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140528142320.GC13012@pad.redhat.com>
Date: Tue, 3 Jun 2014 00:18:34 -0400
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <DA524584-24CD-42C5-9DCB-B5CD2A7F2CC6@primarydata.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com> <1400787148-25941-42-git-send-email-bfields@redhat.com> <20140528080945.GA6797@infradead.org> <20140528140151.GB13012@pad.redhat.com> <5385EEF5.9050904@gmail.com> <20140528142320.GC13012@pad.redhat.com>
To: Bruce Fields <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 28, 2014, at 10:23 AM, J. Bruce Fields <bfields@redhat.com> wrote:

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
>> 
>> I'll eventually be using this case for READ_PLUS.  I'll be sure to
>> send problems your way! :)
> 
> Great, thanks.
> 
> Actually my main question there is how to handle 4.2 in pynfs.
> 
> 4.1 and 4.0 are entirely separate codebases.  We definitely don't want
> to do that again.

I strongly agree!

> 
> There's not much point re-running all the 4.1 tests over 4.2.  Maybe all
> we may need is to say "use minor version 2 on this compound" in tests of
> the new features.
> 
> But I haven't even tried to figure out how to tell pynfs about the new
> .x files.

I’ve made a lot of pynfs cleanups recently - mostly on the client test side 
(the nfs4.1 server), but they may make this a bit easier. I’ll clean them up
and share asap.

I was just adding new xdr to pynfs and AFAIK it's xdrgen has no include
support, so we’re stuck tacking things on the end of nfs4.x. Would it be
worthwhile for me to add some type of include support? Minor versions and
layouts could stay in separate .x files - that sounds much cleaner to me.

-dros

