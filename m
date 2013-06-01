Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:35252 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946Ab3FALd7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Jun 2013 07:33:59 -0400
Received: by mail-vc0-f173.google.com with SMTP id ht10so1709180vcb.32
        for <linux-nfs@vger.kernel.org>; Sat, 01 Jun 2013 04:33:58 -0700 (PDT)
MIME-Version: 1.0
From: William Dauchy <wdauchy@gmail.com>
Date: Sat, 1 Jun 2013 13:33:38 +0200
Message-ID: <CAJ75kXa858MgWZ5A5dt+EswJyR4rJx1ke5Siv8hxds5FPJz_ww@mail.gmail.com>
Subject: nfsv4 mount with noexec
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I've been testing a nfsv4 client based on a 3.8.13 kernel with the
following additional patches:
a3c3cac SUNRPC: Prevent an rpc_task wakeup race
f448bad NFSv4: Fix a thinko in nfs4_try_open_cached
eb54d43 NFS: Fix security flavor negotiation with legacy binary mounts

the mount options are:
type nfs4
rw,nosuid,nodev,noexec,noatime,nodiratime,vers=4.0,rsize=32768,wsize=32768,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,local_lock=none

Even with the noexec option, I'm still able to execute local binaries
on the mounted file system.
Am I wrong on something? I didn't had the issue on a 3.4.x

Regards,

--
William
