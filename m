Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35224 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686AbcCJPh0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2016 10:37:26 -0500
Received: by mail-wm0-f41.google.com with SMTP id l68so35960177wml.0
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2016 07:37:25 -0800 (PST)
MIME-Version: 1.0
From: Martin Houry <martinhoury@gmail.com>
Date: Thu, 10 Mar 2016 16:37:04 +0100
Message-ID: <CAEUt8VKgAoqiHfDHXLXZc7Ude2NwKxRHLJ_kYcQ2fXzyRuJAdQ@mail.gmail.com>
Subject: NFS4.1 Session Trunking state of development
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, I'm Martin Houry, I'm a student and I want to know for my
master thesis the state of development of session trunking in the
NFS4.1 Client compared to the RFC 5661.
I've already seen the implementation of Andy Adamson and I wonder if
there is some points of the RFC that are not implemented yet ? like :

"The client should be prepared for the possibility that
eir_server_owner values may be different on subsequent EXCHANGE_ID
requests made to the same network address [...] the client should
cease to use those forms, either by dropping connections or by adding
sessions."

or

"Clients SHOULD reliably verify if connections between different
network paths are in fact associated with the same NFSv4.1 server and
usable on the same session"

So I want to do a "TO DO" list in order to see what the session
trunking will look like at the end of his implementation in the v4.1
and in a second step compare it to other protocols supporting
multipath.

Kind regards,
Martin Houry
