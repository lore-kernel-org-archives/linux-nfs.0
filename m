Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53978 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab3HOQEf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 12:04:35 -0400
Received: by mail-pd0-f180.google.com with SMTP id y10so989192pdj.25
        for <linux-nfs@vger.kernel.org>; Thu, 15 Aug 2013 09:04:33 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 15 Aug 2013 12:04:33 -0400
Message-ID: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
Subject: server mountpoint busy after unexporting nfs4 share
From: Martin Hicks <mort@bork.org>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm wondering if I'm missing something or if this is a bug.

A NFS4 export has active clients.  The mount is removed from
/etc/exports and 'exportfs -r' is run.  Clients immediately start
getting 'Stale file handle' errors, but the mountpoint is still busy
and cannot be unmounted.  Killing off nfsd solves the problem, but is
undesirable for obvious reasons.

On debian linux, kernel version 3.10-2-amd64,  with nfs-utils 1.2.8.

Thanks,
mh

-- 
Martin Hicks P.Eng.      |         mort@bork.org
Bork Consulting Inc.     |   +1 (613) 266-2296
