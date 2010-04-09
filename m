From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
Date: Fri, 9 Apr 2010 11:00:14 -0400
Message-ID: <p2h89c397151004090800we4aa8123jd01d2411bcc59375@mail.gmail.com>
References: <loom.20100407T160936-119@post.gmane.org>
	 <201004081739.21853.thomas.wunder@swt-bamberg.de>
	 <q2z4d569c331004081158v447450e7sc962c1e3e84de0d@mail.gmail.com>
	 <201004091115.27725.thomas.wunder@swt-bamberg.de>
	 <y2o4d569c331004090750zeb56bf58udb7bbfb3277832c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Wunder <thomas.wunder@swt-bamberg.de>,
	Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f193.google.com ([209.85.222.193]:62661 "EHLO
	mail-pz0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756Ab0DIPAV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Apr 2010 11:00:21 -0400
Received: by pzk31 with SMTP id 31so3331793pzk.33
        for <linux-nfs@vger.kernel.org>; Fri, 09 Apr 2010 08:00:21 -0700 (PDT)
In-Reply-To: <y2o4d569c331004090750zeb56bf58udb7bbfb3277832c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is this the infamous 'test-export' call that should be removed?

-->Andy

On Fri, Apr 9, 2010 at 10:50 AM, Kevin Coffman <kwc@citi.umich.edu> wro=
te:
> On Fri, Apr 9, 2010 at 5:15 AM, Thomas Wunder
> <thomas.wunder@swt-bamberg.de> wrote:
>> On Thursday 08 April 2010 20:58:49 you wrote:
>>> Sorry, I missed that, or forgot. =A0And you still get "mount : only=
 root
>>> can mount ..." if you do "mount /mnt/net" as tomkrb ?? =A0If so, th=
at
>>> seems like a bug.
>>
>> No, with that entry each user is able to invoke mount. The problem i=
s that
>> mount is carried out with uid=3D0 then.
>>
>>> Yes, because under sudo, you are running as root.
>> obviously...
>>
>> I'm wondering if there's a chance to run mount with a non-root uid a=
t all. On
>> the other hand is that really needed? I mean I just want it to pass =
the
>> calling user's uid to the rpc.gssd...
>>
>> By the way the rpcsec_gss_krb5 is loaded.
>>
>>> =A0You said you had this working for the case where root did the mo=
unt
>>> using a keytab though, correct? =A0It can also be caused by a misma=
tch
>>> of sec flavors. =A0(i.e., is the server exporting with krb5p?)
>> Yes, it worked fine when i used a keytab-file with the key for the c=
lient-
>> machine-principal in it. When i issued mount everything worked fine.=
 The
>> problem with this kind of setup is just that this would simply be so=
me kind of
>> host-based authentication and I can't trust the people which will us=
e the
>> clients as much to use a keytab file. They could simply boot from a =
LiveCD,
>> memstick etc. and steal that keytab file...
>> I've double checked that krb5p is specified in the server's /etc/exp=
orts as
>> well as in the client's /etc/fstab (i've also tried it with "krb5" o=
n both
>> sides but that didn't make any difference) .
>>
>> Does it matter whether those two flags match before the security con=
text is
>> completely established at all?
>
> I tried a user mount yesterday and it worked fine, but I had a keytab
> on the machine. =A0Looking closer today, I see two upcalls coming up =
for
> the user-mount case. =A0The first has uid 0, as you say. =A0The secon=
d was
> with my uid. =A0Removing my keytab causes the mount to fail as you ar=
e
> seeing. =A0Sorry to take so long to figure that out.
>
> I don't think this has always been the case. =A0Something might have
> changed with the new kernel mount code?
>
> Copying Chuck to see if he knows more...
>
> K.C.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
