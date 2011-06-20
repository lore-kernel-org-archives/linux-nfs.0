Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63269 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab1FTTGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 15:06:41 -0400
Received: by fxm17 with SMTP id 17so1178053fxm.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2011 12:06:40 -0700 (PDT)
Reply-To: tigran.mkrtchyan@desy.de
Date: Mon, 20 Jun 2011 21:06:40 +0200
Message-ID: <BANLkTinoJ9eeYxQHRB2wVRfF0dS8R88dcQ@mail.gmail.com>
Subject: missing verifier with rpcsec_gss
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

this is what I am observing with v4.0 and v4.1.
sometimes, mostly on RPCSEC_GSS_DESTROY,
in the PC calls missing verifier. This is against my
server and linux server.

Packets attached. Look at them packet 15.
100% reproducible.


I tried vanilla 2.6.39 and 3.0.0-rc3 from
git://linux-nfs.org/~trondmy/nfs-2.6.git<http://linux-nfs.org/~trondmy/nfs-2.6.git
 9cff1ffd4d477f541d5644f0ec25ee origin/linux-next

Regards,
 Tigran.
