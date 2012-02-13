Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:33968 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752463Ab2BMKCA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 05:02:00 -0500
Date: Mon, 13 Feb 2012 11:01:51 +0100
From: <whats_up@gmx.net>
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
Message-ID: <20120213110151.1424c09d@little-poseidon>
In-Reply-To: <4F355CD2.6040603@steve-ss.com>
References: <20120210154526.7b504146@little-poseidon>
	<4F35512A.9050500@steve-ss.com>
	<20120210184154.03fb6907@little-poseidon>
	<4F355CD2.6040603@steve-ss.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> Officially, you should not export from a pseudo root. Please see the 
> last few lines in the link I sent.

I removed the pseudo root entry.
/etc/exports:
/srv/opt    *(sec=sys:krb5,rw,sync,no_subtree_check)

but now I get:
Feb 13 10:43:45 tm mountd[18045]: Kernel does not have pseudo root support.
Feb 13 10:43:45 tm mountd[18045]: NFS v4 mounts will be disabled unless fsid=0
Feb 13 10:43:45 tm mountd[18045]: is specfied in /etc/exports file.

Also I can't mount on client anymore:

# mount -t nfs4 <server-fqdn>:/opt /opt
mount.nfs4: mounting ...:/opt failed, reason given by server:
  No such file or directory

# mount -t nfs4 :/srv/opt /opt
mount.nfs4: mounting ...:/srv/opt failed, reason given by server:
  No such file or directory



> man rpc.gssd(8) adds:
> <quote>
> Previous versions of
> rpc.gssd used only "nfs/*" keys found within the keytab. To be more 
> consistent with other implementations, we now look for specific
> keytab entries. The search order for keytabs to be used for "machine 
> credentials" is now:
> <HOSTNAME>$@<REALM>
> root/<hostname>@<REALM>
> nfs/<hostname>@<REALM>
> host/<hostname>@<REALM>

> I see your setup uses the root principal. If you still get access 
> denied, create another keytab with just the machine$ and host/fqdn
> keys. I can remember having to fiddle with nfs-utils and keytabs on
> openSUSE at some stage last year.

I started with host/... and nfs/... principals and got an access denied
error while mounting. Thus I added the root principal also. 

Which of the four mentioned keys are necessary, resp. which combinations
are sufficient? Or do I always need host, nfs and root?

regards
  knut
