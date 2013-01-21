Return-Path: linux-nfs-owner@vger.kernel.org
Received: from s22.webhostingserver.nl ([195.211.72.238]:63428 "EHLO
	s22.webhostingserver.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756255Ab3AUQFl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 11:05:41 -0500
Received: from localhost ([::1] helo=vdtoorn.nl)
	by s22.webhostingserver.nl with esmtpa (Exim 4.80.1)
	(envelope-from <richard@vdtoorn.nl>)
	id 1TxJsS-0007VC-Dm
	for linux-nfs@vger.kernel.org; Mon, 21 Jan 2013 17:05:40 +0100
Message-ID: <f5c26f2aeca8be1bdca00072e749acd6.squirrel@vdtoorn.nl>
In-Reply-To: <26b3643c253ee306d593bb4b20ff095b.squirrel@vdtoorn.nl>
References: <26b3643c253ee306d593bb4b20ff095b.squirrel@vdtoorn.nl>
Date: Mon, 21 Jan 2013 17:05:40 +0100
Subject: Hanging nfs4+krb5 mounts with negative uids?
From: richard@vdtoorn.nl
To: linux-nfs@vger.kernel.org
Reply-To: richard@vdtoorn.nl
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I have a question about nfs-utils. It's about a patch that was submitted,
way back in 2010, fixing hanging mounts because of a int/uint problem:

you can read the commit message at:
http://www.spinics.net/lists/linux-nfs/msg14723.html

This code gets hit, e.g. with the new debian stable release where
nfs-kernel-server/nfs-common is upgraded to 1.2.6-3 (or upgrade
nfs-kernel-server from debian stable to debian unstable). On my nfsv4+krb5
system, this seems to do exactly the opposite of the patch: not fixing,
but in fact introducing a hanging mount.

When I change the code back from unsigned uid's to signed uid's the mount
works again.

Can anyone give me any help understanding why this is, or point me in a
direction in getting this solved? I very well might have just
misconfigured my nfsv4 + krb5 system (asking myself why am I getting
negative uids?)

Some more information to help debugging:

1) I'm running a VM as a kerberos KDC/admin server (debian sid/unstable)
2) I'm running a second VM as a nfsv4 server configured to use this
kerberos VM (debian squeeze/stable)
3) All VM's are running linux kernel 3.7 (no modules, crypto stuff
configured), time is synchronized by ntpdate
4) On both the nfs-server as an nfs-client, I can succesfully mount using
krb5/5i/5p.

Problem: once I dist-upgrade the nfs-server to unstable where
nfs-utils=1.2.6-3, the mount hangs as described in debian bug #682709.
When I delete the newly acquired
machine credential /tmp/krb5cc_machine_***, and retry the mount, the
syslog error is the following:

ERROR: GSS-API: error in gss_acquire_cred(): Unspecified GSS failure.
Minor code may provide more information - Unknown error

I have a patch available for 1.2.6-3 (basically the opposite of the
commit), that works for my environment. Just a few lines, can paste if
anyone is interested.

Thanks for the help!

Richard van den Toorn
(The Netherlands)



