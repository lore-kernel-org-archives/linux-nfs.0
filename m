Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail8.surf-town.net ([212.97.132.48]:35542 "EHLO
	mailgw6.surf-town.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752289Ab0FJQyE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 12:54:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by mailgw6.surf-town.net (Postfix) with ESMTP id 89E1A5F972
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jun 2010 18:23:36 +0200 (CEST)
Received: from mailgw6.surf-town.net ([127.0.0.1])
	by localhost (mailgw6.surf-town.net [127.0.0.1]) (amavisd-new, port 10027)
	with LMTP id CEzFVSqntCmE for <linux-nfs@vger.kernel.org>;
	Thu, 10 Jun 2010 18:23:30 +0200 (CEST)
Received: from squirrel-webmail.surftown.com (unknown [10.32.13.4])
	by mailgw6.surf-town.net (Postfix) with ESMTP id 96BFD60018
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jun 2010 18:23:30 +0200 (CEST)
Message-ID: <ca08f669da2043ef43bc2874117044ec.squirrel@squirrel-webmail.surftown.com>
Date: Thu, 10 Jun 2010 18:23:30 +0200 (CEST)
Subject: NFSv4 - new file permission issue
From: sascha@rhein.se
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear all,

this is my very first mail to a mailing list, so please bear with me.

I have a setup of an NFSv4 server, together with OpenLDAP and MIT Kerberos
based on XEN virtualised Debian Lenny dom installations, currently running
with kernel "2.6.26-2-xen-amd64".

All is running smoothly and I am successfully using NFS to export the
users home folders, accessing it from several Linux distributions.

However, when I am exporting folders for groups the newly created object
(file or folder) inherits the group-id from the parent object. Never the
less it does not inherit the permission level (read, write, execute).

To my knowledge there are two possible solutions. The first one would be
to set the umask on each client machine in the "/etc/profile" file or in a
file within the users homefolder.

The other one would be to use posix ACLs and this is the preferred
solution to me. I am able to set the desired ACLs on the server with the
"setfacl" command, but I can't see them from the client side.

My question is what is necessary to achive a successful permission
handling. I am correct with my wish to use ACLs or are there other
recommendations? Should I use the umask setting on the client side
instead?

There must be other organizations facing this very same issue and I am
certain that there is an easy solution to this, but I just can't seem to
find it.

Any help or hint is welcome.

Thanks
Sascha




