Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:40176 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab1HLUsP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 16:48:15 -0400
Date: Fri, 12 Aug 2011 16:48:09 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: two callback patches
Message-ID: <20110812204809.GA4760@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

When you get a chance, could you pull these into pnfs-all-latest?  You'll
find them on the head of my for-benny branch, and I assume upstream.

commit 3070296f2b3ddc094bda51286c3e9687d59d2a22
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 2 14:50:40 2011 -0400

    NFSv4.1: Return NFS4ERR_BADSESSION to callbacks during session resets
    
    If the client is in the process of resetting the session when it receives
    a callback, then returning NFS4ERR_DELAY may cause a deadlock with the
    DESTROY_SESSION call.
    
    Basically, if the client returns NFS4ERR_DELAY in response to the
    CB_SEQUENCE call, then the server is entitled to believe that the
    client is busy because it is already processing that call. In that
    case, the server is perfectly entitled to respond with a
    NFS4ERR_BACK_CHAN_BUSY to any DESTROY_SESSION call.
    
    Fix this by having the client reply with a NFS4ERR_BADSESSION in
    response to the callback if it is resetting the session.
    
    Cc: stable@kernel.org [2.6.38+]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a8446678ba8b850bcac2286c6ed803c339049096
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 2 14:50:39 2011 -0400

    NFSv4.1: Fix the callback 'highest_used_slotid' behaviour
    
    Currently, there is no guarantee that we will call nfs4_cb_take_slot() even
    though nfs4_callback_compound() will consistently call
    nfs4_cb_free_slot() provided the cb_process_state has set the 'clp' field.
    The result is that we can trigger the BUG_ON() upon the next call to
    nfs4_cb_take_slot().
    
    This patch fixes the above problem by using the slot id that was taken in
    the CB_SEQUENCE operation as a flag for whether or not we need to call
    nfs4_cb_free_slot().
    It also fixes an atomicity problem: we need to set tbl->highest_used_slotid
    atomically with the check for NFS4_SESSION_DRAINING, otherwise we end up
    racing with the various tests in nfs4_begin_drain_session().
    
    Cc: stable@kernel.org [2.6.38+]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
