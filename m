Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51321 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521Ab0DGP3Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Apr 2010 11:29:16 -0400
Received: by gwb19 with SMTP id 19so606866gwb.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Apr 2010 08:29:15 -0700 (PDT)
In-Reply-To: <loom.20100407T160936-119@post.gmane.org>
References: <loom.20100407T160936-119@post.gmane.org>
Date: Wed, 7 Apr 2010 11:29:09 -0400
Message-ID: <p2l4d569c331004070829q7c6148d7kec7d0f93b1a5d2ba@mail.gmail.com>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
From: Kevin Coffman <kwc@citi.umich.edu>
To: Tom <thomas.wunder@swt-bamberg.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 7, 2010 at 10:37 AM, Tom <thomas.wunder@swt-bamberg.de> wrote:
> I'm trying to set up a kerberized NFSv4 client to mount a share using a local
> ticket (obtained by PAM when the user logged into the shell) instead of a
> machine specific ticket (i.e. I'd like to do user-based authorization). I
> already managed to get machine based authentification/authorization working for
> a test but i can't (and i don't want to) use local keytab files for storing the
> machine keys on the client machines in my production environment.
>
> I'm running the rpc.gssd with the "-n -vvv -rrr" to make it consider user
> tickets too.
> Now, when I try to mount the share to "/mnt/net" (the according fstab-line
> looks like "dnsdhcp:/ /mnt/net  nfs4  sec=krb5p,user 0 0") the credentials
> cache of the user which is doing the mount is not being used. The second
> log message  reads
> "rpc.gssd[888]: getting credentials for client with uid 0 for server <srvname>"
> Googling around a bit i found out that some other people managed to make mount
> use the uid of the initiating user rather than 'root'(uid=0) (though they seem
> to have other problems...).
>
> I'm not quite sure what is wrong with my setup and therefore i tried to dig
> into the code of gssd. The only thing i found is that the uid (0 in my case)
> is read from a file "clntXX/krb5" (within a pipefs) which is obviously
> written by the kernel.
>
> A kernel update to 2.6.32-19 (i'm using ubuntu karmic on an amd64 machine)
> didn't make it any better.
>
> Complete Log (client): http://pastebin.com/s7B2W7ie
> The user ticket (i'm running the mount-command from an account of a user which
> is authenticated via kerberos (MIT Kerberos5)) resided in
> /tmp/krb5cc_10002_H6OYu0
> Here's what klist said http://pastebin.com/Lrrs3AwM
> And this is the client's krb5.conf: http://pastebin.com/JChsVNJQ
>
> I'm really desperate now because i've been working on this problem for nearly
> two weeks now and i couldn't get by...
>
> Can you suggest me how to specify which user should be utilized to carry out
> the mount? (Did I misconfigure something?)
>
>
> By the way i've already downloaded the source-code of the nfs-utils
> (ver. 1.2.0) and modified
> void handle_krb5_upcall(struct clnt_info *clp)
> from
> gssd/gssd_proc.c
> to statically set uid to 10002 (just for testing what will happen) and it's
> pretty interesting what comes out:
> http://pastebin.com/Qi1rWMLC
>
> Thanks in advance!

By the looks of your /etc/fstab entry, the system (root) will try to
mount /mnt/net automatically.  You could try adding the "noauto"
option and then manually issuing the mount command as the user.  (Or
use automount?)

K.C.
