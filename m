Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:63978 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbbBYSnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 13:43:03 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so8238855igj.4
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 10:43:02 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 25 Feb 2015 20:43:01 +0200
Message-ID: <CANhJxzzyf88rUdC1ntg2poZw4K=aYeqww6PrBWarop5PAdWHBg@mail.gmail.com>
Subject: little help please regarding pNFS
From: Hetz Ben Hamo <hetz@hetz.biz>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

(Apologizing for posting here, in the #linux-nfs channel no one answered...)

I'm reading about pNFS server implementation in Linux with iSCSI and
I'm afraid that the docs in linux-nfs.org don't help a lot when it
comes to understanding the iSCSI block share..

Here is a simple scenario:

Machine A is iSCSI Target, which will share a LUN to pNFS
Machine B is pNFS Server (which will be also MDS)
Machines C,D,E - Linux clients.

If I understood the docs correctly, I'll need to run an iSCSI
initiator on Machine B to discover the LUN from machine A, blkmapd
will mount it, I'll need to format it (using parted), and only then i
can share this LUN?

If so, I can do this today using even NFS v3 without pNFS, unless I
really missed something.

Could someone share some info about iSCSI LUN sharing with pNFS, and
if possible - a simple example would be welcome (links are welcome too
... ;) )

Thanks
