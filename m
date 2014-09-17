Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:46684 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756415AbaIQWTv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2014 18:19:51 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so12470qgd.33
        for <linux-nfs@vger.kernel.org>; Wed, 17 Sep 2014 15:19:50 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 17 Sep 2014 23:19:50 +0100
Message-ID: <CAEEfLy5Mtu76gy0COS4CkE0-Upe39xDxynRCLnG=VA9-GLrdSw@mail.gmail.com>
Subject: Close to open consistency
From: Richard Hayden <r.hayden@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi there,

I have some queries regarding NFS' implementation of close to open
consistency. I hope this is the correct forum.

I believe the following to be obviously correct from the various
references on the subject: if I open, write a new file on one client,
close it and then immediately attempt to open and read the file on
another client, I will always see the file as created by the first
client (assuming no other intervening actions by other clients).

However what if, instead of the second client calling open on the
file, it immediately calls just exec (assume the file is an
executable)? Presumably at some point in the exec call it is at least
implicitly invoking some of the functionality of open but is the above
consistency still guaranteed here? Is it only explicit calls to open
which maintain the consistency?

Thanks!
