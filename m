Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519AbaGOPJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:45 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 00/15] libtirpc: New Debugging Interface
Date: Tue, 15 Jul 2014 11:09:19 -0400
Message-Id: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was brought to my attention there is large
amount of debugging in libtirpc but the library 
had to be recompiled to access it. 

With the precedence being set with the old librpcsecgss
and libnfsidmap where debugging can be set by the
application, I thought it would be a good idea to
build a similar interface in libtirpc. 

A lot of these changes is in code that's not use or
even compiled but there is now one unified interface
we can build on.

The first patch defines the interface so I will not
repeat it here, but the interface is modeled after
a simplify xlog, used by a number of daemons.  The
interface can log messages to strderr or syslog but 
not both. Trying to keep it as simple as possible.

The debugging levels are broken down by:

level 1 - only error messages 
level 2 - "I get here" type of messages
level 3 - "I got this value" type of messages
level 4 - hex dumps and other wordy messages


Steve Dickson (15):
  libtirpc: New configurable debugging routines
  gss_log: Convert existing gss debugging routines
  gss_log: Removed DEBUG defines
  gss_log_status: reformat output to use one line.
  git_log_status: Add function name to status message
  libtirpc_debug: Converted the rest of the #ifdef DEBUGs
  gss_log: Replace gss_log_debug with LIBTIRPC_DEBUG macros
  print_rpc_gss_sec: Make sure logging to stderr is enabled.
  Clean up: Remove newlines from a couple debugging calls.
  svcauth_des: Convert local debug() calls to LIBTIRPC_DEBUG() calls
  key_call: Convert local debug() calls to LIBTIRPC_DEBUG() calls
  clnt_bcast: Convert local debug() calls to LIBTIRPC_DEBUG() calls
  rpcb_clnt: Convert fprintf calls to LIBTIRPC_DEBUG() calls
  svc_dg: Convert fprintf calls to LIBTIRPC_DEBUG() calls
  auth_des: Converted some of the debugging syslog calls to
    LIBTIRPC_DEBUG() calls

 src/Makefile.am    |  4 +--
 src/auth_des.c     | 11 ++++----
 src/auth_gss.c     | 45 ++++++++++++++------------------
 src/authgss_prot.c | 76 +++++++++++++++++++++---------------------------------
 src/clnt_bcast.c   | 36 ++++++++------------------
 src/debug.c        | 64 +++++++++++++++++++++++++++++++++++++++++++++
 src/debug.h        | 49 +++++++++++++++++++++++++++++++++++
 src/getpublickey.c | 13 +++++-----
 src/key_call.c     | 21 ++++++---------
 src/netnamer.c     | 20 ++++++--------
 src/rpcb_clnt.c    | 65 +++++++++++++++-------------------------------
 src/svc_auth_des.c | 32 +++++++++++------------
 src/svc_auth_gss.c | 29 +++++++++++++--------
 src/svc_dg.c       | 51 +++++++++++++++++-------------------
 14 files changed, 282 insertions(+), 234 deletions(-)
 create mode 100644 src/debug.c
 create mode 100644 src/debug.h

-- 
1.9.3

