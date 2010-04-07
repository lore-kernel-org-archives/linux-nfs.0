Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from urz32.uni-bamberg.de ([141.13.240.32]:4804 "EHLO
	urz32.UNI-BAMBERG.DE" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208Ab0DGXXI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 19:23:08 -0400
From: thomas.wunder@swt-bamberg.de
To: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
Date: Thu, 8 Apr 2010 01:11:29 +0200
References: <loom.20100407T160936-119@post.gmane.org> <p2l4d569c331004070829q7c6148d7kec7d0f93b1a5d2ba@mail.gmail.com>
In-Reply-To: <p2l4d569c331004070829q7c6148d7kec7d0f93b1a5d2ba@mail.gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201004080111.29452.thomas.wunder@swt-bamberg.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> By the looks of your /etc/fstab entry, the system (root) will try to
> mount /mnt/net automatically.  You could try adding the "noauto"
> option and then manually issuing the mount command as the user.  (Or
> use automount?)
> K.C.
I'm pretty sure that it doesn't try to automatically mount the share on 
startup since there is no log entry that would indicate such an attempt.
I already tried to do the mount as a user (which is authenticated via kerberos 
such that there is a valid ticket for that user) the logs (that i have posted) 
are showing what comes out of it. If I try to do the mount without the fstab-
entry (i.e. mount -t nfs4 -o sec=krb5p dnsdhcp:/ /mnt/net) it is being 
rejected on the grounds that only root can perform a mount. 'sudo' doesn't 
work currently (i've got some problems with my PAM config for sudo) so I 
haven't had any chance to try it out...

I've already set up automount but it actually does exactly the same as if I 
ran mount manually as described above.

I'm totally confused because I don't understand what people like
http://thread.gmane.org/gmane.linux.nfsv4/5893
might have done to perform a mount with normal user privileges. If it was 
really mandatory to be root (as stated by Andy Adamson in the other message) 
then I wouldn't really understand why they should have implemented the uid 
passing using that pipefs file....

