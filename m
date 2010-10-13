Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60803 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab0JMKcQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 06:32:16 -0400
Received: by bwz15 with SMTP id 15so3063397bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Oct 2010 03:32:15 -0700 (PDT)
Date: Wed, 13 Oct 2010 06:32:14 -0400
Message-ID: <AANLkTikoiWGYs+nEtP7YoBkzsc6c0dBhwkxZzYKc7k3h@mail.gmail.com>
Subject: LAYOUTGET/LAYOUTRETURN/CB_RECALL sequencing
From: Fred Isaman <iisaman@netapp.com>
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here is my outline of how to deal with layout stateid and RPC races.
There are two methods outlined, though both end up being similar.  The
first resolves issues by storing replies and processing them in same
order they are processed on the server.  The second by tossing any
LAYOUTGET replies we get that we notice were done before a
LAYOUTRETURN we processed.  Any input you have would be appreciated.

Fred

The pro/cons of each that I see are:

ordered list:
pro:
  Works well with segmented layouts
  Not wasting effort, sending LAYOUTGETs only to ignore the replies.
This becomes more of an issue when segmented layouts come into play.
con:
  Somewhat more complicated code.
  Delay issues - we may wait unecessarily if we have sent a bunch of
LAYOUTGETs with no interspersed LAYOUTRECALLs (though this could be
avoided by tracking more data.  As a future optimization, we could
process an LGET reply received while we have no outstanding LRETURNS
sent or preceeding the LGET in the ordered reply list).

barrier:
pro:
  simpler code
  no waiting for delayed replies, just continue on and ignore the
reply when it arives
con:
  LAYOUTGETs sent may be wasted
  method does not generalize well to segmented layouts




ordered list method
==================

list - consists of LGET, LRETURN responses
expected = next seqid we should actively process
STATE of layout cache stateid - one of NONE, ESTABLISHING,
ESTABLISHED, used to ensure only a single LAYOUTGET with an open
stateid goes out, as it gets painful otherwise
ordered list attached to inode contains LGET and LRETURN replies
FIFO list attached to nfs_client contains CB_RECALL data

LAYOUTGET
  in get_layoutstateid:
    if STATE is NONE, wait for outstanding==0, then grab open stateid,
move state to ESTABLISHING, expected = 1
    if STATE is ESTABLISHING, wait until STATE changes
    if STATE is ESTABLISHED, grab layout stateid
  in prepare:
    if matches any entry in FIFO list, wait, then go back to get_layoutstateid
    outstanding++
  in done:
    put reply on list, ordered by seqid
  in post processing:
    while first's seqid == expected or infinity:
      pull first off list
      if LAYOUTGET:
        insert into inode layout cache
      else if LAYOUTRETURN:
        remove from inode layout cache
      update or invalidate the layout stateid
      outstanding--, on zero wake waiters
      expected++
      free memory
      move STATE to ESTABLISHED if necessary, and wake waiters

CB_RECALL:
  in RPC thread:
    add details to FIFO list hung on nfs_client
    mark lsegs invalid to start draining io (could done in LRETURN)
    in FILE case:
      update layout stateid
      move STATE to ESTABLISHED if necessary, and wake waiters
    schedule worker thread to run (why not use state manager)
    return OK/NOMATCHING depending on if we marked any lsegs invalid
  in worker thread:
    while entry in FIFO list:
      if FILE:
        wait for expected == CB_RECALL's seqid
	expected++
      cycle through FILE LAYOUTRETURNS that need to be sent (or
forgotten - used to drain io)
      wait for those to finish
      send non-FILE LAYOUTRETURN if needed
      wait for reply
      remove entry from FIFO list and wake waiters

LAYOUTRETURN
  in prepare:
    outstanding++
    if FILE
      wait for io to drain
      if triggered by nonFILE, abort the RPC and forget the layout in
post processing
    else
      pass (we've taken care of draining by the time we get here)
  in done:
    if error - who cares? just forget the layout in post processing (seqid==???)
    if ok, add to list, ordered by seqid, with no seqid==infinity
  in post processing
    do same as for layoutget

=========================================================================

barrier method
==============

barrier consists of a stateid, seqid + other.
Anything below the barrier is just ignored, as we were supposed to
wait for it before continuing.  But it is functionally equivalent to
"forget" response.

LAYOUTGET
  in get_layoutstateid:
    if state is NONE, grab open stateid, barrier=0, move state to ESTABLISHING
    if state is ESTABLISHING, wait until state changes
    if state is ESTABLISHED, grab layout stateid
  in prepare
    if matches any entry in FIFO list, wait, then go back to get_layoutstateid
    (we could just send the LAYOUTGET, but since need FIFO list
anyway, why not use it)
    outstanding++
  in post processing
    move state to ESTABLISHED if necessary and wake waiters
    if seqid < barrier, or INRECALL mark on wider struct, toss (forget) layout
    process the layoutget
    update layout stateid
    outstanding--, on zero wake waiters

CB_RECALL
  in RPC thread:
    add details to FIFO list hung on nfs_client
    mark lsegs invalid to start draining io (could done in LRETURN)
    in FILE case:
      update layout stateid
      move STATE to ESTABLISHED if necessary, and wake waiters
      set barrier to CB_RECALL seqid
    schedule worker thread to run (why not use state manager)
    return OK/NOMATCHING depending on if we marked any lsegs invalid
  in worker thread
    while entry in FIFO list:
      cycle through FILE LAYOUTRETURNS that need to be sent (or
forgotten - used to drain io)
      wait for those to finish
      send non-FILE LAYOUTRETURN if needed
      wait for reply
      remove entry from FIFO list and wake waiters

LAYOUTRETURN
  in prepare:
    outstanding++
    if FILE
      wait for io to drain
      if triggered by nonFILE, abort the RPC and forget the layout in
post processing
    else
      pass (we've taken care of draining by the time we get here)
  in done:
    if error - who cares? just forget the layout in post processing
(barrier==???)
    if ok, set barrier to LAYOUTRETURN seqid if exists, else infinity
  in post processing
    if LAYOUT seqid exist:
      update seqid
      set barrier = seqid
    else:
      invalidate stateid (set state to NONE, barrier to 0)
    outstanding--

=========================================================================
