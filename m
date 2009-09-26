From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: [2.6.31] NFS4ERR_GRACE unhandled...
Date: Sat, 26 Sep 2009 19:14:28 +0100
Message-ID: <6278d2220909261114g2e1529dfn4961d450460b00dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:38904 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbZIZSOZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Sep 2009 14:14:25 -0400
Received: by ewy7 with SMTP id 7so3380335ewy.17
        for <linux-nfs@vger.kernel.org>; Sat, 26 Sep 2009 11:14:28 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

After rebooting my 2.6.31 NFS4 server, I see a list of NFS kernel
errors [1] on the 2.6.31 client corresponding to NFS4ERR_GRACE, so
lock or file state recovery failed. Is this expected noting that I
have an internal firewall allowing incoming TCP port 2049 on the
server, and no firewall on the client, however I can't see how it can
thus be callback related?

Many thanks,
  Daniel

--- [1]

[52664.396008] nfs: server x1 not responding, still trying
[53305.376017] nfs: server x1 not responding, timed out
[53305.376024] nfs: server x1 not responding, still trying
[53305.376026] nfs: server x1 not responding, still trying
[53305.376038] nfs: server x1 not responding, still trying
[53305.376041] nfs: server x1 not responding, still trying
[53305.376044] nfs: server x1 not responding, still trying
[53499.312009] nfs: server x1 not responding, still trying
[53551.332276] nfs: server x1 OK
[53551.332679] nfs: server x1 OK
[53551.366774] nfs: server x1 OK
[53551.366820] nfs: server x1 OK
[53551.382566] nfs: server x1 OK
[53551.608916] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.609117] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.609322] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.609528] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.609732] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.609937] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.610142] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.610346] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.610551] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.610757] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.610960] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.611369] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.611779] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.612393] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.619820] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.620070] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.620431] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.633668] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53551.633868] nfs4_reclaim_open_state: unhandled error -10013. Zeroing state
[53611.317298] nfs: server x1 OK
[53611.324266] nfs: server x1 OK
-- 
Daniel J Blueman
