From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
Date: Tue, 20 Apr 2010 23:02:23 -0400
Message-ID: <t2v4d569c331004202002jb25ef307va23f55beb16c2989@mail.gmail.com>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	 <j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
	 <20100417111001.255ad1f4@tlielax.poochiereds.net>
	 <x2l3b6787961004191737p1fb222uc6a5b03d77414826@mail.gmail.com>
	 <t2q4d569c331004200619le2dc3a2em52f27a830d4e7d95@mail.gmail.com>
	 <j2y3b6787961004201719h6d3a7a6nea8f9d6e664a1cbc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Di Pe <dipeit@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f227.google.com ([209.85.217.227]:54564 "EHLO
	mail-gx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab0DUDC1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Apr 2010 23:02:27 -0400
Received: by gxk27 with SMTP id 27so6466627gxk.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 20:02:26 -0700 (PDT)
In-Reply-To: <j2y3b6787961004201719h6d3a7a6nea8f9d6e664a1cbc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 20, 2010 at 8:19 PM, Di Pe <dipeit@gmail.com> wrote:
> On Tue, Apr 20, 2010 at 6:19 AM, Kevin Coffman <kwc@citi.umich.edu> w=
rote:
>> Hi,
>>
>> If I read this right, you replaced krb5-1.8.1 with krb5-1.6.3 and it
>> fixed the problem?
>>
>> As I noted in your original message, you had "allow_weak_crypto =3D
>> true" in your krb5.conf. =A0For NFS, this is required with krb5-1.8
>> where DES is disabled by default. =A0Are you certain you have this
>> specified in your krb5-1.8.1 /etc/krb5.conf?
>
>
> Yes, I'm positive. 1.8.1 does not work 1.6.3 does! =A0This is my curr=
ent setting
>
> [libdefaults]
> =A0 =A0 =A0 =A0default_realm =3D FHCRC.ORG
> =A0 =A0 =A0 =A0clockskew =3D 300
> =A0 =A0 =A0 =A0default_tkt_enctypes =3D des-cbc-crc
> =A0 =A0 =A0 =A0default_tgs_enctypes =3D des-cbc-crc
> =A0 =A0 =A0 =A0permitted_enctypes =3D des-cbc-crc
> =A0 =A0 =A0 =A0allow_weak_crypto =3D true
> =A0 =A0 =A0 =A0forwardable =3D true
>
> I should add one more thing: I was using 2 different NFS servers, a
> NetApp 7.3.1.1 and Opentext NFS Maestro Server 2008 (formerly
> Hummingbird) on Windows 2008 R2 (AD is still 2003 R2). I found out
> today that the NetApp had a corrupted keytab and after repairing that
> it works fine with 1.8.1. NFS Maestro still only works with 1.6.3.
> Since I can use the 1.6.3 rpm package onto newer distros I can live
> with it for the moment if i block the rpm from getting updated but
> it's still kind of a hack.

Do you have access to logs on the server that still doesn't work with
1.8.1?  It seems odd that only this combination would fail.

K.C.
