Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:48273 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752326AbdFMNcA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Jun 2017 09:32:00 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 700BA2807EC
        for <linux-nfs@vger.kernel.org>; Tue, 13 Jun 2017 15:31:58 +0200 (CEST)
Date: Tue, 13 Jun 2017 15:31:57 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Andy Adamson <andros@netapp.com>
Message-ID: <991293071.14131572.1497360717136.JavaMail.zimbra@desy.de>
Subject: "nfs4_discover_server_trunking unhandled error" on Ctrl-C
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If I hit Ctrl-C during mount, then I see following message in the log file:

 NFS: nfs4_discover_server_trunking unhandled error -512. Exiting with error EIO


produced at nfs4state.c:2533. Is this expected behavior?

Tigran.
