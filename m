Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f50.google.com ([209.85.215.50]:41599 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbaLJGJk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2014 01:09:40 -0500
Received: by mail-la0-f50.google.com with SMTP id pn19so1799834lab.23
        for <linux-nfs@vger.kernel.org>; Tue, 09 Dec 2014 22:09:38 -0800 (PST)
Date: Wed, 10 Dec 2014 08:09:29 +0200
From: Timo Teras <timo.teras@iki.fi>
To: Steve Dickson <SteveD@redhat.com>
Cc: David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
Message-ID: <20141210080929.13c1fa30@vostro>
In-Reply-To: <54876A0C.3090109@RedHat.com>
References: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu>
	<20141209104236.2204671c@vostro>
	<24f5038cdd74837afb8a53887eb4b803@hardeman.nu>
	<54871E87.7000300@RedHat.com>
	<20141209202652.GA32738@hardeman.nu>
	<54876A0C.3090109@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 09 Dec 2014 16:30:52 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 12/09/2014 03:26 PM, David Härdeman wrote:
> > On Tue, Dec 09, 2014 at 11:08:39AM -0500, Steve Dickson wrote:
> >> On 12/09/2014 09:01 AM, David Härdeman wrote:
> >>> On 2014-12-09 09:42, Timo Teras wrote:
> >>>> On Tue, 09 Dec 2014 09:16:59 +0100
> >>>> David Härdeman <david@hardeman.nu> wrote:
> >>>>> At least the readline() function could be implemented using
> >>>>> read/write (instead of fread/fwrite) and a dynamic buffer...no?
> >>>>
> >>>> It's extra complexity. I'd rather not add it unless it's
> >>>> required. My understanding about the communication mechanism
> >>>> with kernel is that it's not required. Why have code that would
> >>>> never be used?
> >>>
> >>> I agree that it depends on your view. I tend to be very sceptical
> >>> of arbitrary limitations unless they have a very good reason
> >>> (like measurable and relevant performance impact), I doubt that's
> >>> the case here.
> >> Your skeptical-ability of arbitrary limitations has become very
> >> clear in the last few hours... ;-) I guess I'm indifferent about
> >> it... From reading your gssd patch set, it is a bit more artful
> >> not to use fixed size buffers but again, I'm indifferent... That
> >> said... if patches appear removing these fixed buffers they
> >> definitely would be considered... 
> >>
> >>>
> >>> It's up to the maintainer though, I just wanted to point it out :)
> >> My understanding these patches were needed to make nfs-utils
> >> compatible with the musl c-library. That is the case, correct? 

Yes. It is because musl FILE implementation uses writev() and readv()
with multiple buffers, and the kernel side does not handle that.

Also, the write side was very brittle even with glibc, it probably was
broken with large messages.

> > The fread/fwrite removal seems reasonable, yes. The removal of the
> > readline() function though (which could be implemented using normal
> > read/malloc/realloc) seems less so.....IMHO.
> > 
> Patches welcome! 8-)

Normally having upper limits is also a security feature. It means the
other end cannot force the client code to receive so large messages
that it runs out of memory. Though, in this case the other end is
kernel and to be trusted.

Though, it probably helps catch potential errors. The messages from
kernel really cannot exceed that length. If they do, it's an error
anyway. The message structure pretty much ensures this.

In my opinion the dynamic allocation is a step backward, rather then
forwards. It adds potential failure (out of memory), is not required,
and it does not add any features either.

IMHO, "just because it used to be so" is a bad excuse. And it would
just cause additional code making harder to debug and easier to fail.
Why add complexity when it can be done simpler?

just my five cents,
Timo
