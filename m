Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:46307 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758722Ab0DHOSQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Apr 2010 10:18:16 -0400
Received: by gwb19 with SMTP id 19so1192660gwb.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Apr 2010 07:18:14 -0700 (PDT)
In-Reply-To: <201004080111.29452.thomas.wunder@swt-bamberg.de>
References: <loom.20100407T160936-119@post.gmane.org>
	 <p2l4d569c331004070829q7c6148d7kec7d0f93b1a5d2ba@mail.gmail.com>
	 <201004080111.29452.thomas.wunder@swt-bamberg.de>
Date: Thu, 8 Apr 2010 10:18:11 -0400
Message-ID: <j2u4d569c331004080718xd96444d3z532fcd92af5755b2@mail.gmail.com>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
From: Kevin Coffman <kwc@citi.umich.edu>
To: thomas.wunder@swt-bamberg.de
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 7, 2010 at 7:11 PM,  <thomas.wunder@swt-bamberg.de> wrote:
>> By the looks of your /etc/fstab entry, the system (root) will try to
>> mount /mnt/net automatically.  You could try adding the "noauto"
>> option and then manually issuing the mount command as the user.  (Or
>> use automount?)
>> K.C.
> I'm pretty sure that it doesn't try to automatically mount the share on
> startup since there is no log entry that would indicate such an attempt.
> I already tried to do the mount as a user (which is authenticated via kerberos
> such that there is a valid ticket for that user) the logs (that i have posted)
> are showing what comes out of it. If I try to do the mount without the fstab-
> entry (i.e. mount -t nfs4 -o sec=krb5p dnsdhcp:/ /mnt/net) it is being
> rejected on the grounds that only root can perform a mount. 'sudo' doesn't
> work currently (i've got some problems with my PAM config for sudo) so I
> haven't had any chance to try it out...
>
> I've already set up automount but it actually does exactly the same as if I
> ran mount manually as described above.
>
> I'm totally confused because I don't understand what people like
> http://thread.gmane.org/gmane.linux.nfsv4/5893
> might have done to perform a mount with normal user privileges. If it was
> really mandatory to be root (as stated by Andy Adamson in the other message)
> then I wouldn't really understand why they should have implemented the uid
> passing using that pipefs file....

Hello Tom,

To allow non-root users to do the mount, add the "user" option to the
entry in /etc/fstab.  Then the user with uid 10002 should be able to
kinit and then mount.  (Note that in this case, there is no need for
the "-n" option to rpc.gssd.)

K.C.
