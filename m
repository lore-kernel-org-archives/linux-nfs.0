Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:38773 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaFCOYS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 10:24:18 -0400
Received: by mail-ie0-f173.google.com with SMTP id lx4so6041812iec.32
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jun 2014 07:24:18 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20140603141021.GA14321@pad.redhat.com>
Date: Tue, 3 Jun 2014 10:24:13 -0400
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <7FFBAE05-C5F6-4F98-817C-546851F559EC@primarydata.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com> <1400787148-25941-42-git-send-email-bfields@redhat.com> <20140528080945.GA6797@infradead.org> <20140528140151.GB13012@pad.redhat.com> <5385EEF5.9050904@gmail.com> <20140528142320.GC13012@pad.redhat.com> <DA524584-24CD-42C5-9DCB-B5CD2A7F2CC6@primarydata.com> <20140603141021.GA14321@pad.redhat.com>
To: Bruce Fields <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 3, 2014, at 10:10 AM, J. Bruce Fields <bfields@redhat.com> wrote:

> On Tue, Jun 03, 2014 at 12:18:34AM -0400, Weston Andros Adamson wrote:
>> On May 28, 2014, at 10:23 AM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> There's not much point re-running all the 4.1 tests over 4.2.  Maybe all
>>> we may need is to say "use minor version 2 on this compound" in tests of
>>> the new features.
>>> 
>>> But I haven't even tried to figure out how to tell pynfs about the new
>>> .x files.
>> 
>> I’ve made a lot of pynfs cleanups recently - mostly on the client test side 
>> (the nfs4.1 server), but they may make this a bit easier. I’ll clean them up
>> and share asap.
>> 
>> I was just adding new xdr to pynfs and AFAIK it's xdrgen has no include
>> support, so we’re stuck tacking things on the end of nfs4.x. Would it be
>> worthwhile for me to add some type of include support? Minor versions and
>> layouts could stay in separate .x files - that sounds much cleaner to me.
> 
> That does sound cleaner, but is that how the ietf's .x files work?
> 
> It looks like
> 
>  http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-dot-x-26.txt
> 
> just copies all the 4.1 definitions.
> 
> I may not understand what you're proposing.

Oh, yeah. I was thinking more about layouts - like the flex file draft - that don’t
repeat definitions and instead reference other xdr definitions.

I don’t know if there is any restriction in the IETF that all types within a .x
have to be defined by that .x. If not, does it make sense to change the 4.2
spec to only have new types, or to prune out the differences for pynfs?

-dros

