Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:53839 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab1G1Opj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 10:45:39 -0400
Received: by yia27 with SMTP id 27so1845620yia.19
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2011 07:45:38 -0700 (PDT)
In-Reply-To: <1311863605.3332.17.camel@perseus.themaw.net>
References: <1311683346-16881-1-git-send-email-steved@redhat.com>
	<8A84CF7D-9579-4645-AE5D-FE8358F466C0@gmail.com>
	<4E2F2DE6.5030500@RedHat.com>
	<1311728231.3473.7.camel@perseus.themaw.net>
	<1311729784.3473.14.camel@perseus.themaw.net>
	<A8F3853A-9C75-4F65-8EEB-88DD13C3FF9B@gmail.com>
	<1311734445.3473.19.camel@perseus.themaw.net>
	<8A86A2AE-A1C7-473E-931A-CF03BD690CE6@gmail.com>
	<1311819970.3332.3.camel@perseus.themaw.net>
	<E21E3A76-96FD-4F44-8187-70532FD3D6AD@gmail.com>
	<1311863605.3332.17.camel@perseus.themaw.net>
Date: Thu, 28 Jul 2011 10:45:37 -0400
Message-ID: <CAFMMQGsURY2SWv4pM5T-ofLhbVzCvC8a_+ASqJm_ZCEOXww-6g@mail.gmail.com>
Subject: Re: [Libtirpc-devel] [PATCH] Autofs configure fails to detect IPv6
 when libtirpc is enabled
From: Chuck Lever <chucklever@gmail.com>
To: Ian Kent <ikent@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        autofs mailing list <autofs@linux.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 10:33 AM, Ian Kent <ikent@redhat.com> wrote:
> On Thu, 2011-07-28 at 07:20 -0400, Chuck Lever wrote:
>> On Jul 27, 2011, at 10:26 PM, Ian Kent wrote:
>> >
>> > Umm ...
>> >
>> > Why is __rpcb_findaddr() declared in the public header files but not
>> > defined anywhere is the source?
>> >
>> > Why is __rpcb_findaddr_timed() defined in the source but not defined in
>> > the public header files?
>>
>> This version of libtirpc was split from the Sun version over a decade
>> ago when the code was immature.  So you're going to find this kind of
>> thing in many places.
>
> Yes, I was aware of that, but haven't paid enough attention to the doc.
>
>>
>> The TI-RPC API is defined in 816-1435.  You really shouldn't consider
>> using any of the interfaces defined in the headers but not in that
>> doc, as those are internal interfaces and can change.
>
> Ummm .. rpcb_getaddr() might be what I'm looking for, I'll look further.
>
>>
>> On the other hand, we have at least two important RPC-based
>> applications that can make use of this interface.  I wonder if it
>> makes sense to harden that API but leave it hidden, so apps external
>> to the library can depend on it.
>
> Yeah, but if I can achieve what I need without it that's the way I'll
> go. It looks like I might not be able to do what I want the way I want
> with ti-rpc but it is still too early to tell. It's also too early to
> tell if ti-rpc actually already does some or all of what I need already.
> Time will tell.
>
> One example of something I need is to control the timeout, not the
> timeout for interactions after the client is constructed but the timeout
> of the client construction itself, including any queries to rpcbind that
> may be needed (hence why I want to do that manually too).

Yes, nfs-utils does this too.  See support/nfs/rpc_socket.c.  It looks
a lot like what is done in autofs's lib/rpc_subs.c.

-- 
"Blast this Christmas music!  It's joyful _and_ triumphant!"
 -- The Grinch
