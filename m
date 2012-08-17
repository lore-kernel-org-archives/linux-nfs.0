Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailservice.tudelft.nl ([130.161.131.5]:55525 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237Ab2HQQSI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2012 12:18:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id 725262B802A
	for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2012 17:58:07 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.73])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id dovDh8weLjDn for <linux-nfs@vger.kernel.org>;
	Fri, 17 Aug 2012 17:58:06 +0200 (CEST)
Received: from smtp-a.tudelft.nl (smtp-a.tudelft.nl [130.161.180.7])
	by mx2.tudelft.nl (Postfix) with ESMTP id DAD9E2B802B
	for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2012 17:58:06 +0200 (CEST)
Received: from [172.19.3.32] (61-120.ipact.nl [82.210.120.61])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-a.tudelft.nl (Postfix) with ESMTP id BF991B3A62
	for <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2012 17:58:06 +0200 (CEST)
Message-ID: <502E69FC.7080608@tudelft.nl>
Date: Fri, 17 Aug 2012 17:57:48 +0200
From: Richard <rsmits-l@tudelft.nl>
Reply-To: Richard Smits <R.Smits@tudelft.nl>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfsv4 state id errors
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

A couple of weeks agoo we upgraded our Netapp filer to 8.1.1RC1. We have
always had trouble with NFS and state id's. Resulting in hanging clients.

Some bugs were fixed in 8.1.1 but still trouble.

Now we have the following errors in our client messages file, after a hang.

What does this : NFS: "v4 server srv returned a bad sequence-id error!"
means ?
----
Aug 17 14:08:23 tudxxxxxx kernel: [622014.866818] NFS: v4 server srvxxx
 returned a bad sequence-id error!
Aug 17 14:08:23 tudxxxxxx kernel: [622014.872143] NFS: v4 server
returned a bad sequence-id error on an unconfirmed sequence
ffff8801112dcc20!
Aug 17 14:08:23 tudxxxxxx kernel: [622014.872871] NFS: v4 server
returned a bad sequence-id error on an unconfirmed sequence
ffff8801112dcc20!
Aug 17 14:08:23 tudxxxxxx kernel: [622015.170658] NFS: v4 server
returned a bad sequence-id error on an unconfirmed sequence
ffff8801112e6820!
Aug 17 14:08:23 tudxxxxxx kernel: [622015.278260] NFS: v4 server srvxxx
 returned a bad sequence-id error!
Aug 17 14:08:23 tudxxxxxx kernel: [622015.651868] NFS: v4 server srvxxx
 returned a bad sequence-id error!
Aug 17 14:08:24 tudxxxxxx kernel: [622016.051741] NFS: v4 server srvxxx
 returned a bad sequence-id error!
Aug 17 14:08:25 tudxxxxxx kernel: [622017.155713] NFS: v4 server srvxxx
 returned a bad sequence-id error!
Aug 17 14:08:25 tudxxxxxx kernel: [622017.346225] NFS: v4 server
returned a bad sequence-id error on an unconfirmed sequence
ffff8800bcf39620!
Aug 17 14:08:25 tudxxxxxx kernel: [622017.349781] NFS: v4 server
returned a bad sequence-id error on an unconfirmed sequence
ffff8800bcf39620!
Aug 17 14:08:25 tudxxxxxx kernel: [622017.350840] NFS: v4 server
returned a bad sequence-id error on an unconfirmed sequence
ffff8800bcf39620!

