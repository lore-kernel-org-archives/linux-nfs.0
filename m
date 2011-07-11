Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.uvm.edu ([132.198.101.168]:40444 "EHLO smtp1.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758083Ab1GKQjA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2011 12:39:00 -0400
Received: from planck.uvm.edu (planck.uvm.edu [132.198.104.181])
	(authenticated bits=0)
	by smtp1.uvm.edu (8.14.2/8.14.2) with ESMTP id p6BGUhuw031102
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2011 12:30:44 -0400
From: Benjamin Coddington <bcodding@uvm.edu>
Content-Type: text/plain; charset=us-ascii
Subject: svcgssd problem against libgssapi_krb5
Date: Mon, 11 Jul 2011 12:30:42 -0400
Message-Id: <822CE753-04C1-44BE-888A-A258D6737E7A@uvm.edu>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I have a problem building svcgssd from nfs-utils-1.2.3:

svcgssd[15145]: DEBUG: serialize_krb5_ctx: lucid version!
svcgssd[15145]: ERROR: GSS-API: error in gss_export_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been established) - (0x00007fff)
svcgssd[15145]: ERROR: failed serializing krb5 context for kernel
svcgssd[15145]: WARNING: handle_nullreq: serialize_context_for_kernel failed

I found that the svcgssd I built ran differently than the one that works from a major distro.

My broken one does this:

gssint_mechglue_initialize_library () at g_initialize.c:135
135	{
(gdb) bt
#0  gssint_mechglue_initialize_library () at g_initialize.c:135
#1  0x00007ffff79a9f75 in gss_indicate_mechs (minorStatus=0x7fffffffe50c, mechSet_out=0x7fffffffe500) at g_initialize.c:220
#2  0x00000000004021ae in gssd_check_mechs () at gss_util.c:241
#3  0x0000000000402777 in main (argc=3, argv=<value optimized out>) at svcgssd.c:239


But if I remove -lgssapi_krb5, svcgssd works fine, and behaves like the one from the distro:

gss_initialize () at g_initialize.c:148
148	{
(gdb) bt
#0  gss_initialize () at g_initialize.c:148
#1  0x00007ffff6e82f6e in gss_indicate_mechs (minor_status=0x7fffffffe50c, mech_set=0x7fffffffe500) at g_indicate_mechs.c:54
#2  0x000000000040216e in gssd_check_mechs () at gss_util.c:241
#3  0x0000000000402737 in main (argc=3, argv=<value optimized out>) at svcgssd.c:239


Ben