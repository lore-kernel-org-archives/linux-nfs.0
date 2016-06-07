Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:32788 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbcFGUCU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 16:02:20 -0400
Received: by mail-yw0-f194.google.com with SMTP id y6so24256342ywe.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2016 13:02:20 -0700 (PDT)
MIME-Version: 1.0
From: sebastien cabaniols <sebastien.cabaniols@gmail.com>
Date: Tue, 7 Jun 2016 22:02:19 +0200
Message-ID: <CALipME=i0H5bAHf3AuXU2EnEDOmmzK58x4D7Oz+YDp5MsUao4g@mail.gmail.com>
Subject: does the linux NFS client support for failover to a replica share
 (read-only share)
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello linux-nfs mailing list.

I would like to know if the linux nfs client included in current
versions of the kernel supports fail-over to a replica on another nfs
server, I am using (manually) synchronized read-only shares...

I found very few information on Google about this topic and I suspect
this is not implemented.

I actually tried to setup this using SLES12SP1 (3.12.49 kernel) but I
failed so far. I am not attached to this distribution/version in
particular, just trying to see it working for real.

( I did some "rpcdebug -m nfs" session and it seems the fs_locations
is not getting properly populated on my setup )

Any confirmation this should work or not would actually help me.

THX.


note from the exports man page:

       replicas=path@host[+host][:path@host[+host]]
              If  the  client  asks for alternative locations for the
export point, it will be given this list of alternatives.
              (Note that actual replication of the filesystem must be
handled elsewhere.)
