Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailservice.tudelft.nl ([130.161.131.5]:36427 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab2JXNYr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2012 09:24:47 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id 9DB5C108C0E0
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 15:04:57 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.74])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id OotX87riz33D for <linux-nfs@vger.kernel.org>;
	Wed, 24 Oct 2012 15:04:57 +0200 (CEST)
Received: from smtp-a.tudelft.nl (smtp-a.tudelft.nl [130.161.180.7])
	by mx3.tudelft.nl (Postfix) with ESMTP id 3E58B108C039
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 15:04:57 +0200 (CEST)
Received: from pc-rsmits.ws.tudelft.net (x049176.tudelft.net [131.180.49.176])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-a.tudelft.nl (Postfix) with ESMTP id 32922B3A62
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 15:04:57 +0200 (CEST)
Message-ID: <5087E778.4040909@tudelft.nl>
Date: Wed, 24 Oct 2012 15:04:56 +0200
From: Richard Smits <R.Smits@tudelft.nl>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: nfs4 state id errors
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

We have a open support case at Netapp for this but I hope someone 
recognizes these errors and can give us a clue how to solve this.

We have a Netapp 3170 NFS4 server with krb5 security. Our Suse 11.2 
clients give these errors.

---------------------------------------
RPC call returned error 13
NFS: v4 server returned a bad sequence-id error on an unconfirmed 
sequence ffff88020d80de20!

nfs4_reclaim_locks: unhandled error -10026. Zeroing state
nfs4_reclaim_open_state: unhandled error -10026. Zeroing state
NFS: v4 server srvxxx  returned a bad sequence-id error!
---------------------------------------

After the last line (zeroing state) the client goes into a hang.

Client versions :

nfs-client-1.2.3-18.23.1
krb5-client-1.6.3-133.48.48.1

Kernel : 3.0.38-0.5-default

I have reported this earlier on this list, but i hope someone reads it 
who recognises it. Will save us a lot of headaches....

Greetings, Richard Smits
ICT, Technical University Delft.
The Netherlands
R.Smits@tudelft.nl
