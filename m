Return-Path: linux-nfs-owner@vger.kernel.org
Received: from spam.physics.umanitoba.ca ([130.179.72.17]:58966 "EHLO
	hauhet.physics.umanitoba.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754093Ab2GXPeJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 11:34:09 -0400
Received: from [130.179.72.253] (shodan.physics.umanitoba.ca [130.179.72.253])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hauhet.physics.umanitoba.ca (Postfix) with ESMTP id A0DC265946
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jul 2012 10:10:56 -0500 (CDT)
Message-ID: <500EBB69.5000205@physics.umanitoba.ca>
Date: Tue, 24 Jul 2012 10:12:41 -0500
From: Maiko Langelaar <maiko@physics.umanitoba.ca>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: 2 NFS server for the same mount point ?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A bit of history first.

Our original NFS server (Server A) is getting old. It exports a
bunch of files systems, ie: /home/u3, /home/u7, under which are
a bunch of user directories.

To minimize downtown, my strategy was to tackle migration to a
new NFS server (Server B) user by user (we don't have tons). In
the end what I have now is all the user directories on Server B,
but I have kept the original mount points still exported on the
Server A, with all the user subdirectories now defined as symbolic
links to the new mount points on Server B. This has worked very
well actually, very little downtime for anyone, and people did
not have to stop computation runs (some of which take weeks).

Now comes the interesting part.

I want to move the original mount points over to Server B !

Question : Can I export the SAME mount points on 2 NFS servers
for the same subnet ? I figure yes, because any particular NFS
client will *target* a particular server. BUT the RPC nature of
the NFS protocol makes me a bit nervous about doing so.

Can anyone provide their experience in this ?

For what it's worth, Server B defaults V4, Server A is V3,
with a mix of V3 and V4 clients.

Much appreciated.

Maiko Langelaar
IT Physics and Astronomy
University of Manitoba
204-474-9273
