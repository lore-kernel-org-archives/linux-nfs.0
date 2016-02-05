Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34691 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbcBEQoL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 11:44:11 -0500
Received: by mail-oi0-f47.google.com with SMTP id w5so44310152oie.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 08:44:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFJNCsSM=pccUnQmtq6ZMDdHNAmxOBZGYV2_0iNzfLsMQ@mail.gmail.com>
References: <CAN-5tyFJNCsSM=pccUnQmtq6ZMDdHNAmxOBZGYV2_0iNzfLsMQ@mail.gmail.com>
Date: Fri, 5 Feb 2016 11:44:10 -0500
Message-ID: <CAHQdGtSETwRy7ry_ZkMo5M1uTwG6hvWMUmYRkJjgDob+g-RwUA@mail.gmail.com>
Subject: Re: Question about XID use in sunrpc
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 10:37 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> I have a question regarding the implementation of sunrpc use of XID
> when the client receives an AUTH_ERROR. The code (clnt.c line 1933)
> explicitly comments that a new XID should be acquired and releases the
> currently rpc task (and gets a new one). Why is that? Since the
> operation is "replayed" but with the new credentials, why shouldn't
> the same XID be used?
>
> The RPC RFC says that XID is used by the server to detect
> retransmissions. It's not clear if in the specs means "retransmission"
> == tcp retransmissions. If so then it explains why the client uses the
> same XID.
>

The questions you are asking come under the header "RPC lore" rather
than "RPC law". The use of XIDs as a basis for replay caching is not
speced out in any RFC. The closest thing we have in the form of
documentation is Ric Werme's presentation at the 1996 Connectathon:
http://nfsv4bat.org/Documents/ConnectAThon/1996/werme1.pdf

Basically, those comments are there in the Linux code to denote issues
found when interoperability testing with server implementations that
are probably now long dead, but might still be in use somewhere.

Cheers
 Trond
