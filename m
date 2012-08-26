Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pobox.sfu.ca ([142.58.101.28]:39157 "EHLO pobox.sfu.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab2HZSHx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Aug 2012 14:07:53 -0400
Received: from d142-058-174-021.wireless.sfu.ca (d142-058-174-021.wireless.sfu.ca [142.58.174.21])
	(authenticated bits=0)
	by pobox.sfu.ca (8.13.6/8.13.5/SFU-6.0G) with ESMTP id q7QGvDSO012041
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Sun, 26 Aug 2012 09:57:13 -0700 (PDT)
From: Derek Warren <warren@sfu.ca>
Content-Type: text/plain; charset=us-ascii
Subject: NFSv4 client failed to create krb5 context?
Date: Sun, 26 Aug 2012 09:57:13 -0700
Message-Id: <5F4FD3CC-EC7C-44E9-BC8F-2AF9A0650A41@sfu.ca>
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Apple Message framework v1278)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pardon me for barging in on a kernel-oriented list, but I'm hoping some
of the NFS wizards here can shed some light on something...

We have Active Directory-bound/ID mapping working and Kerberized NFSv4 
shares on CentOS 6.3.

World-readable and -executable directories are readily accessed, but 
private directories fail:

ID mapping works identically on the server and the client:
	[joeuser@nfsclient ~]$ id joeuser
	uid=56055(joeuser) gid=6502(domain users) groups=6502(domain users),1000001(BUILTIN\users)

... and we can mount directories with -o sec=none/krb5/krb5i/krb5p:
	[joeuser@nfsclient ~]$ sudo mount -t nfs4 -o proto=tcp,port=2049 -o sec=krb5p nfsserver.example.com:/testdir /mnt
	
	[joeuser@nfsclient ~]$ ls -l /mnt
	drwx------ 2 user1    domain users 4096 Aug  3 11:43 user1
	drwx------ 2 adbinder domain users 4096 Aug 17 15:20 adbinder
	drwx------ 2 joeuser  domain users 4096 Aug  3 11:43 joeuser

... but we hit the wall here:
	[joeuser@nfsclient ~]$ cd /mnt/joeuser
	bash: cd: joeuser: Permission denied

At this point, we get a warning from rpc.gssd:

nfsclient rpc.gssd[10256]: using FILE:/tmp/krb5cc_56055_od8D5s as credentials cache for client with uid 56055 for server nfsserver.example.com
nfsclient rpc.gssd[10256]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_56055_od8D5s
nfsclient rpc.gssd[10256]: creating context using fsuid 56055 (save_uid 0)
nfsclient rpc.gssd[10256]: creating tcp client for server nfsserver.example.com
nfsclient rpc.gssd[10256]: creating context with server nfs@nfsserver.example.com
nfsclient rpc.gssd[10256]: WARNING: Failed to create krb5 context for user with uid 56055 for server nfsserver.example.com
nfsclient rpc.gssd[10256]: WARNING: Failed to create krb5 context for user with uid 56055 for server nfsserver.example.com
nfsclient rpc.gssd[10256]: doing error downcall

Can anyone tell me why this mount succeeds but accessing
non-world-readable/executable directories would fail?

Kerberos appears to be working up to this point: we can kinit -k NFSCLIENT$
and do a `net ads keytab nfs` without entering a password... and since 
Kerberos appears to be fine, I'm turning to the linux-nfs list. :-)

I've tried making the share user-mountable and calling `mount` as an
ordinary user (i.e., without using machine credentials) but this fails
with the same error.

Details about our setup and more debug output is available in this post:
http://mailman.mit.edu/pipermail/kerberos/2012-August/018351.html

Random guesses and suggestions from those more experienced than me
would be more than welcome at this point. :-)



Many thanks,
--
Derek Warren, IT Services, Research Computing Group, SFU

