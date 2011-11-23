Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-dy0-f46.google.com ([209.85.220.46]:65385 "EHLO
	mail-dy0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1KWTyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Nov 2011 14:54:12 -0500
Received: by dyi18 with SMTP id 18so125460dyi.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Nov 2011 11:54:11 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Wed, 23 Nov 2011 20:54:06 +0100
Message-ID: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com>
Subject: nfs-utils and libnfsidmap
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

today was tracing a bug in nfs-utils/libnfsidmap and after a log
debugging located it and
finally realized that it's already fixed by Steve Dickson (
http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=d22ef3f525d71b565fcc688557273a6cabeeb71a
). Nevertheless during
this procedure it turned out that there is quite some code duplicated
between nfs-utils and
libnfsidmap.

Questions:
   a) why nfs-utils duplicates some part of libnfsidmap and still depends o it
   b) is there readon for code duplication? Licensing or so
   c) what ww need to do to get rid of duplication

I expect the answer of 'c' will contain something like time and man power.
I am volunteering to to pend some time on it.

Regards,
   Tigran.
