Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757127AbZLDUZw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:52 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Fri,  4 Dec 2009 15:25:35 -0500
Message-Id: <1259958347-9031-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fix session reset deadlocks Version 4.

These patches apply to 2.6.32

Fix races and bugs as well as implement a new session draining scheme
designed by Trond.

0001-nfs41-add-create-session-into-establish_clid.patch
0002-nfs41-rename-cl_state-session-SETUP-bit-to-RESET.patch
0003-nfs41-nfs4_get_lease_time-will-never-session-reset.patch
0004-nfs41-call-free-slot-from-nfs4_restart_rpc.patch
0005-nfs41-free-the-slot-on-unhandled-read-errors.patch
0006-nfs41-fix-switch-in-nfs4_handle_exception.patch
0007-nfs41-fix-switch-in-nfs4_recovery_handle_error.patch
0008-nfs41-don-t-clear-tk_action-on-success.patch
0009-nfs41-remove-nfs4_recover_session.patch
0010-nfs41-nfs41-fix-state-manager-deadlock-in-session.patch
0011-nfs41-drain-session-cleanup.patch
0012-nfs41-only-state-manager-sets-NFS4CLNT_SESSION_SETU.patch

Testing:

CONFIG_NFS_V4_1
v41 mount: Connectathon tests passed. PyNFS testclient.py SESSIONRESET tests

The INJECT_ERROR testclient.py test where NFS4ERR_BADSESSION was returned
every 50th SEQUENCE operation and the session destroyed
durring a Connectathon basic test run.  This passed all but the bigfile test
where the check_lease op->renew_lease nfs4_proc_sequence state manager
session reset call could not get a slot due to the async error handler
restart read/write RPC's getting slots prior to any rpc tasks waiting on
queues. This will be fixed in a subsequent patch set.

v4 mount: Connectathon tests passed.

no CONFIG_NFS_V4_1
v4 mount: Connectathon tests passed.

-->Andy
~                                              

