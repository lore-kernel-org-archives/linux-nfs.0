From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/14] RFC: IPv6 support for kernel NSM
Date: Fri, 24 Oct 2008 14:09:46 -0400
Message-ID: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41633 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbYJXSLV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:21 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBGvW009392
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:16 -0500
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9O6egMq018186
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:12 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OI9kV8023866
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:09:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm interested in some comments on the following proposal for supporting
IPv6 in the kernel's NSM implementation.

The first three patches simply add support for using an IPv6 address for
the mon_name argument when nsm_use_hostnames is not set.  Nothing too
complex there.  It re-uses the address display functions in
fs/lockd/host.c to generate the address string.

The middle eight patches replace the contents of the "priv" argument to
the SM_MON upcall and the NLM_SM_NOTIFY downcall.  We use a 32-bit raw
IPv4 address today, so we have to replace it with something else to
support IPv6 properly.  I propose using an arbitrary unique cookie for
each nsm_handle.

This is a little more extensive than a simple change here, as I
decided to re-organize this code a little bit to make it simpler to
understand and modify.  The idea is to move as many NSM-related data
structures and functions into fs/lockd/mon.c.  The creation and
interpretation of the cookies should happen in just this one place,
and not be spread around in fs/lockd/host.c and in lockd's XDR layer.
It should be easier to understand and relate the various pieces now.

The last three patches are clean-ups that result from this
reorganization.

This patch set builds, but has not been tested.  Constructive comments
and review are welcome.

---

Chuck Lever (14):
      NSM: Use same helpers in nsm_get_handle() and nsm_lookup_rebooted()
      NLM: Remove "create" argument from nsm_find()
      NSM: Remove include/linux/lockd/sm_inter.h
      NSM: Replace IP address as our nlm_reboot lookup key
      NSM: Add nsm_lookup() function
      NLM: Decode "priv" argument of NLM_SM_NOTIFY as an opaque
      NLM: Change nlm_host_rebooted() to take a single nlm_reboot argument
      NSM: Generate "priv" argument when nsm_handle is created
      NSM: Move NSM program and procedure numbers to fs/lockd/mon.c
      NSM: Move NSM-related XDR data structures to lockd's xdr.h
      NSM: Move NSM-related function and variable declarations to lockd.h
      NSM: Support IPv6 version of mon_name
      NSM: Move nsm_find() to fs/lockd/mon.c
      NLM: Beef up NLM address display function


 fs/lockd/clntproc.c            |    1 
 fs/lockd/host.c                |  173 +++++++----------------
 fs/lockd/mon.c                 |  298 ++++++++++++++++++++++++++++++++--------
 fs/lockd/svc.c                 |    1 
 fs/lockd/svc4proc.c            |   13 --
 fs/lockd/svcproc.c             |   13 --
 fs/lockd/svcsubs.c             |    1 
 fs/lockd/xdr.c                 |    5 -
 fs/lockd/xdr4.c                |    5 -
 include/linux/lockd/lockd.h    |   31 +++-
 include/linux/lockd/sm_inter.h |   48 ------
 include/linux/lockd/xdr.h      |   15 +-
 12 files changed, 335 insertions(+), 269 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h

-- 
Chuck Lever
