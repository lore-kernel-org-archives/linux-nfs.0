Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:36818 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbaBMA0g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Feb 2014 19:26:36 -0500
Received: by mail-qc0-f179.google.com with SMTP id e16so16571564qcx.24
        for <linux-nfs@vger.kernel.org>; Wed, 12 Feb 2014 16:26:36 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 12 Feb 2014 16:26:36 -0800
Message-ID: <CACShw34+btEz3mz6Yt17XLDH7WGkiJXeF84gHiyVgy-aKEy7MQ@mail.gmail.com>
Subject: Errors on a NFS4/Kerberos setup
From: Brian Demsky <bdemsky@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am running a fresh install of Ubuntu 13.10 on both the client and
server with the
latest version of all packages.  I have MIT kerberos setup using nfsv4
with sec=krb5p.

The kernel version is Linux 3.11.0-15-generic.

I have rpc.gssd and rpc.svcgssd running on the server, and rpc.gssd
running on the client.  I've tried also running rpc.svcgssd on the client
with no changes observed.

Everything seems to mostly work but I get the following errors in the
system log immediately:

On the client I see:
Feb 12 16:00:06 dw-14 rpc.gssd[653]: ERROR:
GSS-API: error in gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No
context has been established) - Unknown error Feb 12 16:00:06 dw-14
rpc.gssd[653]: WARN: failed to free lucid sec context


On the server I see:
Feb 12 15:58:12 plrg rpc.svcgssd[1100]: ERROR: GSS-API: error in
gss_free_lucid_sec_context(): GSS_S_NO_CONTEXT (No context has been
established) - Unknown error
Feb 12 15:58:12 plrg rpc.svcgssd[1100]: WARN: failed to free lucid sec context
Feb 12 15:58:12 plrg kernel: [   26.031833] RPC: AUTH_GSS upcall timed out.
Feb 12 15:58:12 plrg kernel: [   26.031833] Please check user daemon is running.
Feb 12 15:58:30 plrg kernel: [   44.060998] RPC: AUTH_GSS upcall timed out.
Feb 12 15:58:30 plrg kernel: [   44.060998] Please check user daemon is running.

After some time, I also see the following on the client repeated at an
extremely high rate:
Feb 12 07:49:47 dw-14 kernel: [33634.356995] NFS: state manager: check
lease failed on NFSv4 serverplrg.eecs.uci.edu with error 13
Feb 12 07:49:52 dw-14 kernel: [33639.365041] NFS: state manager: check
lease failed on NFSv4 serverplrg.eecs.uci.edu with error 13

Is there anyway to fix these issues?  What do they mean?

Thanks,
Brian
