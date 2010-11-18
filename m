Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58259 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758731Ab0KRP1J convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 10:27:09 -0500
Received: by yxf34 with SMTP id 34so1879703yxf.19
        for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 07:27:09 -0800 (PST)
In-Reply-To: <4CE54128.2070602@blub.net>
References: <4CE294DD.6010508@blub.net>
	<4CE3B3B9.8040208@openoffice.nl>
	<AANLkTi=Vhz+BSeGtYOUavf9Lq0ms2hLjTUyuvGt0gMxj@mail.gmail.com>
	<4CE4F910.4080601@blub.net>
	<AANLkTiktXSPbVJg40-bmum39RNekn8aggnWUSPCYdRb9@mail.gmail.com>
	<4CE54128.2070602@blub.net>
Date: Thu, 18 Nov 2010 10:27:02 -0500
Message-ID: <AANLkTinS4mYVM1aA+-dkb_Q2m3Gz+TVmVPcBBOgAByqf@mail.gmail.com>
Subject: Re: no_root_squash (and valid KRB root-ticket)
From: Kevin Coffman <kwc@citi.umich.edu>
To: Valentijn Sessink <valentyn@blub.net>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 18, 2010 at 10:07 AM, Valentijn Sessink <valentyn@blub.net> wrote:
> Hi Kevin,
>
> Kevin Coffman schreef:
>>>> On your server, you can map "host/client.machine@REALM" to root.  (Or
>>>> "nfs/client.machine@REALM" or "root/client.machine@REALM", depending
>>>> on what key you have on the client.)
>>> As far as I can see, that would mean that anyone
>>> with root rights on the client (thus being able to read the machine
>>> keys) would have root rights on the server share, wouldn't it?
>> Isn't that the equivalent of no_root_squash?  (root on the client ==
>> root on the server)
>
> It used to be, when local UID = server UID was the fine way of
> authenticating - but with KRB authentication, the idea is that you
> authenticate to the server.
>
> To summarize: when your UID=0 on the client, you cannot be root at the
> server, because UID=0 is handled differently by gssd.

Actually, in the case of UID=0, the client's machine credentials are
used.  You can map that Kerberos principal to root on the server.  So
this _is_ possible.

> If you have any
> other UID, you can map this to UID=0 on the server - either by using
> "kinit root" at the client, or by setting up a specific mapping for
> libnfsidmap.

Creating a "root" Kerberos principal is discouraged.  (You might,
however, have a "root/<fqdn>" principal -- that you could use for
machine credentials.)

K.C.
