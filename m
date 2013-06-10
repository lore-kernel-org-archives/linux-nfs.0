Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f179.google.com ([209.85.217.179]:46039 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab3FJIh6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jun 2013 04:37:58 -0400
Received: by mail-lb0-f179.google.com with SMTP id w20so5928480lbh.24
        for <linux-nfs@vger.kernel.org>; Mon, 10 Jun 2013 01:37:57 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 10 Jun 2013 10:37:56 +0200
Message-ID: <CAJO99TmfCTYgyrwgUWUmFNGjhQhtHzA7+YDby_MNH2Bjt5tk2g@mail.gmail.com>
Subject: caching issue with nocto
From: =?ISO-8859-1?Q?Bj=F8rnar_Ness?= <bjornar.ness@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mounting with nocto option drasticly improves performance, but doing
some tests, it seems that if a file is modified, either from the
client doing the mount or other client, the file is never cached
again.

Can this be seen as a bug?

Test:

while true;do time cat /usr/src/linux-3.9.5(include/linux/*.h >/dev/null;done

Stabilizes on ~10ms here with nocto

But then, if touching a file from either same client or other, time
skyrockets, and never gets back to anything near 10ms! Only solution
is to unmount and mount again..


Is this expected behaviour?

--
Bj(/)rnar
