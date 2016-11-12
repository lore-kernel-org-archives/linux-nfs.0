Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55754 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753023AbcKLLIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 12 Nov 2016 06:08:52 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5C6C431B336
        for <linux-nfs@vger.kernel.org>; Sat, 12 Nov 2016 11:08:52 +0000 (UTC)
Received: from [10.10.53.23] (vpn-53-23.rdu2.redhat.com [10.10.53.23])
        by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id uACB8piT009325
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA256 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Sat, 12 Nov 2016 06:08:52 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: CLOSE/OPEN race
Date: Sat, 12 Nov 2016 06:08:50 -0500
Message-ID: <9E2B8A0D-7B0E-4AE5-800A-0EF3F7F7F694@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've been seeing the following on a modified version of generic/089
that gets the client stuck sending LOCK with NFS4ERR_OLD_STATEID.

1. Client has open stateid A, sends a CLOSE
2. Client sends OPEN with same owner
3. Client sends another OPEN with same owner
4. Client gets a reply to OPEN in 3, stateid is B.2 (stateid B sequence 2)
5. Client does LOCK,LOCKU,FREE_STATEID from B.2
6. Client gets a reply to CLOSE in 1
7. Client gets reply to OPEN in 2, stateid is B.1
8. Client sends LOCK with B.1 - OLD_STATEID, now stuck in a loop

The CLOSE response in 6 causes us to clear NFS_OPEN_STATE, so that the OPEN
response in 7 is able to update the open_stateid even though it has a lower
sequence number.

I think this case could be handled by never updating the open_stateid if the
stateids match but the sequence number of the new state is less than the
current open_state.

Any thoughts?

Ben
