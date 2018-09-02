Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:38510 "EHLO
        mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726421AbeIBX1b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Sep 2018 19:27:31 -0400
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
        by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id 2469719C002D
        for <linux-nfs@vger.kernel.org>; Sun,  2 Sep 2018 21:01:49 +0200 (CEST)
Received: from ikr.uni-stuttgart.de (ingress2-c [10.11.14.11])
        by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id 0F7F81A200AE
        for <linux-nfs@vger.kernel.org>; Sun,  2 Sep 2018 21:01:49 +0200 (CEST)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: conflicting requirements betweenn rpc.rquotad and nfs services
Date: Sun, 2 Sep 2018 21:01:47 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201809022101.49019.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we updated to Ubuntu 18.04 on our servers and encounter the following
new problem:

We have no IPv6 interfaces/adresses configured and rpc.rquotad complains
about this and refuses to start - it seems the libtirpc has IPv6 as
a requirement when listed in /etc/netconfig.

When commenting out the v6-related lines in /etc/netconfig, rpc.rquotad
starts.

But without the IPv6 related lines in /etc/netconfig rpcbind no longer
starts and emits error messages which seems a little bit weired.

The services start when we start rpc.rquotad with the v6-lines in
/etc/netconfig commented out and using the original version with the
other services.

Is it intended that rpcbind does not start when /etc/netconfig does
not contain the IPv6-lines? Is there a reason for this?

rpc.rquotad --version says

Quota utilities version 4.03.
Compiled with: USE_LDAP_MAIL_LOOKUP EXT2_DIRECT HOSTS_ACCESS RPC RPC_SETQUOTA BSD_BEHAVIOUR

rpcbind seems to emit no version information

Thanks in advance and best regards

-Ulrich

-- 
Ulrich Gemkow
University of Stuttgart
Institute of Communication Networks and Computer Engineering (IKR)
