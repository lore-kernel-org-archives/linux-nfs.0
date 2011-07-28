Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:44516 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab1G1LU7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 07:20:59 -0400
Received: by qwk3 with SMTP id 3so1262580qwk.19
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jul 2011 04:20:58 -0700 (PDT)
Subject: Re: [Libtirpc-devel] [PATCH] Autofs configure fails to detect IPv6 when libtirpc is enabled
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1311819970.3332.3.camel@perseus.themaw.net>
Date: Thu, 28 Jul 2011 07:20:54 -0400
Cc: Steve Dickson <SteveD@redhat.com>,
        autofs mailing list <autofs@linux.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
Message-Id: <E21E3A76-96FD-4F44-8187-70532FD3D6AD@gmail.com>
References: <1311683346-16881-1-git-send-email-steved@redhat.com> <8A84CF7D-9579-4645-AE5D-FE8358F466C0@gmail.com> <4E2F2DE6.5030500@RedHat.com>  <1311728231.3473.7.camel@perseus.themaw.net> <1311729784.3473.14.camel@perseus.themaw.net> <A8F3853A-9C75-4F65-8EEB-88DD13C3FF9B@gmail.com> <1311734445.3473.19.camel@perseus.themaw.net> <8A86A2AE-A1C7-473E-931A-CF03BD690CE6@gmail.com> <1311819970.3332.3.camel@perseus.themaw.net>
To: Ian Kent <ikent@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 27, 2011, at 10:26 PM, Ian Kent wrote:

> On Tue, 2011-07-26 at 23:30 -0400, Chuck Lever wrote:
>>>> 
>>>> For IPv6 support, use functions that are part of the modern libtirpc
>>>> API.  This is described in Sun doc 816-1435.  You probably will be
>>>> most successful with the "simplified interface" which is described in
>>>> Chapter 4. You might need somewhat more extensive surgery since I'm
>>>> guessing you have separate code paths to invoke the IPv4 and IPv6
>>>> legacy RPC functions; generally speaking that should not be needed
>>>> when using the libtirpc API.
>>> 
>>> I doubt the simplified interface will be adequate since this code was
>>> written because of a need for greater control over timeouts. Perhaps
>>> that won't be the case, I don't know yet.
>> 
>> If you want control over connection timeouts, use the expert-level or
>> bottom-level interfaces.  Otherwise you can set per-RPC timeouts when
>> clnt_call(3t) is invoked.  nfs-utils has some example code
>> (support/nfs/rpc_socket.c is one place to look).
>> 
>>> Your suggestion amounts to saying I need to re-write all my RPC
>> code.
>> 
>> The substantial change with client-side TI-RPC is how CLIENTs are
>> created.  The other RPC operations are similar or the same as they
>> were with the legacy API.  Once you get over getnetconfigent(3t) it's
>> really not as bad as it looks.
>> 
> 
> Umm ...
> 
> Why is __rpcb_findaddr() declared in the public header files but not
> defined anywhere is the source?
> 
> Why is __rpcb_findaddr_timed() defined in the source but not defined in
> the public header files?

This version of libtirpc was split from the Sun version over a decade ago when the code was immature.  So you're going to find this kind of thing in many places.

The TI-RPC API is defined in 816-1435.  You really shouldn't consider using any of the interfaces defined in the headers but not in that doc, as those are internal interfaces and can change.

On the other hand, we have at least two important RPC-based applications that can make use of this interface.  I wonder if it makes sense to harden that API but leave it hidden, so apps external to the library can depend on it.

Such apps would not be portable away from Linux nor to Linux distributions that don't have libtirpc yet.