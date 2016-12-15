Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34721 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752423AbcLOTc6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2016 14:32:58 -0500
Received: by mail-io0-f177.google.com with SMTP id p42so78690979ioo.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 11:32:57 -0800 (PST)
MIME-Version: 1.0
From: Ketan Dixit <ketan.dixit@apcera.com>
Date: Thu, 15 Dec 2016 11:24:08 -0800
Message-ID: <CAOph5DA0Wmx346Q-525iW3JUaVYA=puMv1+sznX1TLtokmqkzQ@mail.gmail.com>
Subject: NFSv4 idmapping issue with AUTH_UNIX
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I was trying the NFS idmapping functionality by creating users with
same name but different IDs and was getting strange results the ls
commands would show me the proper output but the chown command would
fail.

On searching the internet, I found this link

http://dfusion.com.au/wiki/tiki-index.php?page=Why+NFSv4+UID+mapping+breaks+with+AUTH_UNIX


The link basically mentions that for the authentication (identifying
the executor of the command) it uses SunRPC and that sends uid, gid in
integers (Not as names)  Thus chown does not work as the IDs on server
and client differ.

Is there a plan to have the RPC layer send names too, so that NFSv4
idmapping will work in the case of AUTH_UNIX?

Also is it reasonable  overriding the logic in
https://github.com/torvalds/linux/blob/29fbff8698fc0ac1a1d74584b258e0bf18b469f9/net/sunrpc/auth_unix.c#L130
to consider a fixed offset  (in case of unprivileged containers the
UIDs are offseted by some fixed offset like 10000) will address the
issue?


Thanks
Ketan
