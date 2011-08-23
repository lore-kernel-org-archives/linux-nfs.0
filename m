Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:39719 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183Ab1HWAlW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2011 20:41:22 -0400
Received: by vxi9 with SMTP id 9so4620850vxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Aug 2011 17:41:22 -0700 (PDT)
In-Reply-To: <20110823101614.7b597933@notabene.brown>
References: <20110804092141.3461c9ce@notabene.brown>
	<CAKnQG+cs4SLD-YmLwpnXU_gDWrjfmx9+z-E=7J-SUcsP=KhfSg@mail.gmail.com>
	<20110804111357.0d0a6e85@notabene.brown>
	<CAKnQG+dViSmrjhZV1cFZHj98kM0ixyKRLek9OWkJjFUS6YO3cw@mail.gmail.com>
	<20110811154239.322dee1d@notabene.brown>
	<CAKnQG+eV_OCk60wN6E2ub-TxA+6NoALYn8C+1PD51fWUZTpcGQ@mail.gmail.com>
	<20110818191906.13a6261f@notabene.brown>
	<20110818164307.GA24533@fieldses.org>
	<20110823101614.7b597933@notabene.brown>
Date: Mon, 22 Aug 2011 20:41:22 -0400
Message-ID: <CAKnQG+cXxgSYYX++h7nXdYF5hBzWxoUrP62QZEdGffeP99ptYg@mail.gmail.com>
Subject: Re: Problems with kerberos auth - possibly against ADS - since nfs-utils-1.2.3
From: Kevin Coffman <kwc@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 22, 2011 at 8:16 PM, NeilBrown <neilb@suse.de> wrote:
> On Thu, 18 Aug 2011 12:43:07 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
>
>> On Thu, Aug 18, 2011 at 07:19:06PM +1000, NeilBrown wrote:
>> > I think that does exactly describes what we were seeing.
>> > We ended up working around it by adding
>> >
>> >   default_tkt_enctypes = des-cbc-md5 des-cbc-crc des3-cbc-sha1
>> >
>> > to the client config, and recommending a server upgrade.
>> >
>> >
>> > BTW I've been trying to track down why a successful kerberos negotiation
>> > sends a corrupted RPCSEC_GSS_DESTROY request just before closing the
>> > connection.
>>
>> (No useful comment here, just: thanks!  That was driving me crazy, till
>> it just stopped happening for no apparent reason, before I got a chance
>> to look any closer...)
>
> It stopped happening?  You mean it is already fix?  Have I been look at old
> code AGAIN ??
>
> Though I was looking at most recent libtirpc and gssglue and I think I was
> running both of these...  Maybe I had a slightly old krb5-mit library?
>
> confused...
>
> NeilBrown

Hi Neil,
I haven't had a chance to look at this issue.  I don't recall ever
seeing it myself, but I may have just missed it.  I'll try to
replicate the problem on Wednesday -- unless you fix it and send a
patch before that!  ;-)  I've definitely done most of my testing with
fairly recent versions of Kerberos if that is indeed related.

K.C.
