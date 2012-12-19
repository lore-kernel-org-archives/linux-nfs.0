Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.agmk.net ([91.192.224.71]:51112 "EHLO mail.agmk.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753147Ab2LSTIp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2012 14:08:45 -0500
Received: from localhost.localnet (unknown [84.10.194.214])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: pluto@agmk.net)
	by mail.agmk.net (Postfix) with ESMTPSA id 45C0786E974
	for <linux-nfs@vger.kernel.org>; Wed, 19 Dec 2012 19:58:14 +0100 (CET)
From: =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>
To: linux-nfs@vger.kernel.org
Subject: [3.6.11] NFS: Cache request denied due to non-unique superblock keys.
Date: Wed, 19 Dec 2012 19:58:10 +0100
Message-ID: <6078496.RFsWrNWv86@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

i'm testing the 3.6.11 kernel on some small internal nfs network (1 server <-> 2 clients)
and observing such info in dmesg on the client side. could you put some light on this dmesg entry?
is it a bug or misconfiguration? i can provide more information about nfs configuration
if necessary but denying caching doesn't look nicely.

i'm using following nfs related packages:

autofs-5.0.5-1.x86_64
libnfsidmap-0.25-4.x86_64
nfs-utils-1.2.7-1.x86_64
nfs-utils-clients-1.2.7-1.x86_64
nfs-utils-common-1.2.7-1.x86_64

BR,
Paweł.

please CC me on reply.

