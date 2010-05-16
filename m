From: hce <webmail.hce@gmail.com>
Subject: NFS cache
Date: Sun, 16 May 2010 18:26:23 +1000
Message-ID: <AANLkTikZfdnCMm0TkEaVnN2kqVzMZ7CYmbe1YengmRMY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:49633 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab0EPI0Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 04:26:24 -0400
Received: by pzk42 with SMTP id 42so2059268pzk.4
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 01:26:23 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I posted following message on list, but did not see it on list, sorry
if it is duplicated.

I have an application to use NFS over FUSE, if I keep typing "ls" in
the same directory, the client NFS only sent GETATT, no more READDIR,
all directory contents displayed on screen came from NFS cache. That
caused many problems and I'd like to disable NFS client cache. But it
did not work when I add "-o noac" option to mount. Also I don't want
NFS GETATT retransmission during file copy. Appreciate your advice and
sample examples for how to mount nfs to disable client cache and
retransmission.

Thank you.

hce
