Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:60913 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757807Ab0KROZn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 09:25:43 -0500
Received: by yxf34 with SMTP id 34so1826853yxf.19
        for <linux-nfs@vger.kernel.org>; Thu, 18 Nov 2010 06:25:43 -0800 (PST)
In-Reply-To: <4CE4F910.4080601@blub.net>
References: <4CE294DD.6010508@blub.net>
	<4CE3B3B9.8040208@openoffice.nl>
	<AANLkTi=Vhz+BSeGtYOUavf9Lq0ms2hLjTUyuvGt0gMxj@mail.gmail.com>
	<4CE4F910.4080601@blub.net>
Date: Thu, 18 Nov 2010 09:25:42 -0500
Message-ID: <AANLkTiktXSPbVJg40-bmum39RNekn8aggnWUSPCYdRb9@mail.gmail.com>
Subject: Re: no_root_squash (and valid KRB root-ticket)
From: Kevin Coffman <kwc@citi.umich.edu>
To: Valentijn Sessink <valentyn@blub.net>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 18, 2010 at 4:59 AM, Valentijn Sessink <valentyn@blub.net> wrote:
> Kevin Coffman schreef:
>> Did you see my message about "static" mapping for libnfsidmap?
>
> Yes, but it's scope was not immediately clear to me. Also, I couldn't
> find the mapping feature you were mentioning; but my idmapd man page
> comes from the nfs-common sources, while your idmapd.conf example (as
> you explained) comes from libnfsidmap.
>
>> On your server, you can map "host/client.machine@REALM" to root.  (Or
>> "nfs/client.machine@REALM" or "root/client.machine@REALM", depending
>> on what key you have on the client.)
>
> OK, now I understand :) As far as I can see, that would mean that anyone
> with root rights on the client (thus being able to read the machine
> keys) would have root rights on the server share, wouldn't it?

Isn't that the equivalent of no_root_squash?  (root on the client ==
root on the server)

You are free to map any principal to root on the server.  It doesn't
have to be a client's machine credentials.

K.C.
