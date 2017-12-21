Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:37517 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751220AbdLUOpT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Dec 2017 09:45:19 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id CAD3828032A
        for <linux-nfs@vger.kernel.org>; Thu, 21 Dec 2017 15:45:17 +0100 (CET)
Received: from z-mbx-2.desy.de (z-mbx-2.desy.de [131.169.55.140])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id E3DFD1611
        for <linux-nfs@vger.kernel.org>; Thu, 21 Dec 2017 15:45:16 +0100 (MET)
Date: Thu, 21 Dec 2017 15:45:16 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1076094126.762559.1513867516663.JavaMail.zimbra@desy.de>
Subject: blocked client due to sleep with lock
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi all,


when a pNFS client gets the multipath list for a DS with GETDEVICEINFO
it tries to poke all provided ip addresses. By doing that client holds
nfs_clid_init_mutex which is defined in nfs4state.c and calls 
nfs41_discover_server_trunking function. The discovery code waits until
connection get initialized by looping around wait_event_killable called
by nfs_wait_client_init_complete. However, if one of the DS interfaces is
not reachable by the client, the nfs_clid_init_mutex is locked for quite some
time and client can't initialize any other DS, if a parallel request was
issued.

Now, the bonus issue. If DS provides IPv6 address, but client as a link-local
address only, then client will try to use it and first access to the DS will
take some time (400 sec). Moreover, the same situation is observed even
if client has IPv6 only on loopback interface. Unfortunately, looks
like both cases are allowed by IPv6. But with 1200 DSes accessing the data
is quite painful.

Regards,
   Tigran.
