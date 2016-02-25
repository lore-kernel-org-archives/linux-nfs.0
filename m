Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:36125 "EHLO
	mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757854AbcBYQTl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Feb 2016 11:19:41 -0500
Received: by mail-vk0-f53.google.com with SMTP id c3so51999421vkb.3
        for <linux-nfs@vger.kernel.org>; Thu, 25 Feb 2016 08:19:37 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 25 Feb 2016 11:19:36 -0500
Message-ID: <CAF-YAQzN=2B-wKTLOjjYFLTLnvbgA7q85bXX+ACpAH2cDpDeGA@mail.gmail.com>
Subject: "clnt_create: RPC: Unknown host"
From: David Henderson <dhenderson@digital-pipe.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good morning everyone.  I am attempting to connect a client to a
working NFS server, but continue to get the error "clnt_create: RPC:
Unknown host".  I can successfully mount the NFS shares, but I can't
use 'showmount' to get a listing.  On another client, I can
successfully issue the 'showmount' command.  The only difference I can
see between an 'rpcinfo' call on both clients is that the non-working
one is missing the 'nlockmgr' service - both have 'portmapper' and
'status' services.  I've tried searching online and the only
resolutions I could find was editing the /etc/hosts file, but after
doing that I still get the same error.  I'm lost and have no clue how
to proceed.  Been working on this for several days with no end in
sight.  Any help would greatly be appreciated.

Thanks,
Dave
