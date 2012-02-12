Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33482 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677Ab2BLRyL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Feb 2012 12:54:11 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH Version 7] NFSv4.1 Prepare for dynamic session slots
Date: Sun, 12 Feb 2012 12:52:53 -0500
Message-Id: <1329069176-8349-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dynamic session slot code will respond to the server changing the
target_highest_slotid returned in the SEQUENCE operation. To respond to
a changing number of session slots, the static array implementation is
changed to an hlist hashed on slotid with 32 hash buckets.

These patches have been tested against the unchanged static array implementation
with one change: I used only 8 hash buckets so that the hlist would have more
than one entry per hash bucket.

Without the third patch which assigns the slot to be freed to a waiting task
if the slot_table_waitq is non-empy, the hlist implementation does not perform
as well as the static array.

With the third patch, the hlist impementation performs as well as the static
array version.

-->Andy

