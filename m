Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:63051 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933174Ab0DHTFJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Apr 2010 15:05:09 -0400
Received: by gwb19 with SMTP id 19so1317909gwb.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Apr 2010 12:05:08 -0700 (PDT)
In-Reply-To: <201004081739.21853.thomas.wunder@swt-bamberg.de>
References: <loom.20100407T160936-119@post.gmane.org>
	 <201004080111.29452.thomas.wunder@swt-bamberg.de>
	 <j2u4d569c331004080718xd96444d3z532fcd92af5755b2@mail.gmail.com>
	 <201004081739.21853.thomas.wunder@swt-bamberg.de>
Date: Thu, 8 Apr 2010 14:58:49 -0400
Message-ID: <q2z4d569c331004081158v447450e7sc962c1e3e84de0d@mail.gmail.com>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
From: Kevin Coffman <kwc@citi.umich.edu>
To: Thomas Wunder <thomas.wunder@swt-bamberg.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 8, 2010 at 11:39 AM, Thomas Wunder
<thomas.wunder@swt-bamberg.de> wrote:
> On Thursday 08 April 2010 16:18:11 you wrote:
>> On Wed, Apr 7, 2010 at 7:11 PM,  <thomas.wunder@swt-bamberg.de> wrote:
>> >> By the looks of your /etc/fstab entry, the system (root) will try to
>> >> mount /mnt/net automatically.  You could try adding the "noauto"
>> >> option and then manually issuing the mount command as the user.  (Or
>> >> use automount?)
>> >> K.C.
>> >
>> > I'm pretty sure that it doesn't try to automatically mount the share on
>> > startup since there is no log entry that would indicate such an attempt.
>> > I already tried to do the mount as a user (which is authenticated via
>> > kerberos such that there is a valid ticket for that user) the logs (that
>> > i have posted) are showing what comes out of it. If I try to do the mount
>> > without the fstab- entry (i.e. mount -t nfs4 -o sec=krb5p dnsdhcp:/
>> > /mnt/net) it is being rejected on the grounds that only root can perform
>> > a mount. 'sudo' doesn't work currently (i've got some problems with my
>> > PAM config for sudo) so I haven't had any chance to try it out...
>> >
>> > I've already set up automount but it actually does exactly the same as if
>> > I ran mount manually as described above.
>> >
>> > I'm totally confused because I don't understand what people like
>> > http://thread.gmane.org/gmane.linux.nfsv4/5893
>> > might have done to perform a mount with normal user privileges. If it was
>> > really mandatory to be root (as stated by Andy Adamson in the other
>> > message) then I wouldn't really understand why they should have
>> > implemented the uid passing using that pipefs file....
>>
>> Hello Tom,
>>
>> To allow non-root users to do the mount, add the "user" option to the
>> entry in /etc/fstab.  Then the user with uid 10002 should be able to
>> kinit and then mount.  (Note that in this case, there is no need for
>> the "-n" option to rpc.gssd.)
>>
>> K.C.
>>
> I've already added have the "user"-option in my fstab (I also reported that in
> my very first message) such that the entry looks like:
> dnsdhcp:/  /mnt/net nfs4   sec=krb5p,user          0       0

Sorry, I missed that, or forgot.  And you still get "mount : only root
can mount ..." if you do "mount /mnt/net" as tomkrb ??  If so, that
seems like a bug.

> To express it more clearly:
> The user with uid=10002 (username = tomkrb) can do a kinit but i guess it
> doesn't need to if it is already logged into a bash-console using pam_krb5-
> authentication-module. A ticket already exists for that session in the /tmp
> directory and if i modify the "void handle_krb5_upcall(struct clnt_info
> *clp)"-function in gssd_proc.c to not use the uid which is passed by the
> kernel but rather use 10002 (statically) that ticket is also accepted.
>
> Meanwhile i succeeded in getting sudo working. Performing
> sudo mount -t nfs4 -o sec=krb5p dnsdhcp:/ /mnt/net
> from a (physical) console where tomkrb (uid=10002) is logged in also results
> in uid=0 being passed instead of uid=10002.

Yes, because under sudo, you are running as root.

> Is it possible to understand what i'd like to do at all?

Apparently I also skipped the end of your original message where you
overrode the UID and the gss context exchange seemingly worked, but
then failed to write the context to the kernel.  This has usually been
caused by the proper kernel module (rpcsec_gss_krb5) not being loaded.
 You said you had this working for the case where root did the mount
using a keytab though, correct?  It can also be caused by a mismatch
of sec flavors.  (i.e., is the server exporting with krb5p?)

K.C.
