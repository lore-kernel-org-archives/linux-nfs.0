Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:33092 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753881Ab0DIOvG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Apr 2010 10:51:06 -0400
Received: by gwb19 with SMTP id 19so1803407gwb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Apr 2010 07:51:04 -0700 (PDT)
In-Reply-To: <201004091115.27725.thomas.wunder@swt-bamberg.de>
References: <loom.20100407T160936-119@post.gmane.org>
	 <201004081739.21853.thomas.wunder@swt-bamberg.de>
	 <q2z4d569c331004081158v447450e7sc962c1e3e84de0d@mail.gmail.com>
	 <201004091115.27725.thomas.wunder@swt-bamberg.de>
Date: Fri, 9 Apr 2010 10:50:54 -0400
Message-ID: <y2o4d569c331004090750zeb56bf58udb7bbfb3277832c@mail.gmail.com>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
From: Kevin Coffman <kwc@citi.umich.edu>
To: Thomas Wunder <thomas.wunder@swt-bamberg.de>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Apr 9, 2010 at 5:15 AM, Thomas Wunder
<thomas.wunder@swt-bamberg.de> wrote:
> On Thursday 08 April 2010 20:58:49 you wrote:
>> Sorry, I missed that, or forgot.  And you still get "mount : only root
>> can mount ..." if you do "mount /mnt/net" as tomkrb ??  If so, that
>> seems like a bug.
>
> No, with that entry each user is able to invoke mount. The problem is that
> mount is carried out with uid=0 then.
>
>> Yes, because under sudo, you are running as root.
> obviously...
>
> I'm wondering if there's a chance to run mount with a non-root uid at all. On
> the other hand is that really needed? I mean I just want it to pass the
> calling user's uid to the rpc.gssd...
>
> By the way the rpcsec_gss_krb5 is loaded.
>
>>  You said you had this working for the case where root did the mount
>> using a keytab though, correct?  It can also be caused by a mismatch
>> of sec flavors.  (i.e., is the server exporting with krb5p?)
> Yes, it worked fine when i used a keytab-file with the key for the client-
> machine-principal in it. When i issued mount everything worked fine. The
> problem with this kind of setup is just that this would simply be some kind of
> host-based authentication and I can't trust the people which will use the
> clients as much to use a keytab file. They could simply boot from a LiveCD,
> memstick etc. and steal that keytab file...
> I've double checked that krb5p is specified in the server's /etc/exports as
> well as in the client's /etc/fstab (i've also tried it with "krb5" on both
> sides but that didn't make any difference) .
>
> Does it matter whether those two flags match before the security context is
> completely established at all?

I tried a user mount yesterday and it worked fine, but I had a keytab
on the machine.  Looking closer today, I see two upcalls coming up for
the user-mount case.  The first has uid 0, as you say.  The second was
with my uid.  Removing my keytab causes the mount to fail as you are
seeing.  Sorry to take so long to figure that out.

I don't think this has always been the case.  Something might have
changed with the new kernel mount code?

Copying Chuck to see if he knows more...

K.C.
