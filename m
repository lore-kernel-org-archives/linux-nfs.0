From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 08:44:07 -0500
Message-ID: <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
References: <4B7D4E55.4040002@RedHat.com> <20100304201941.GL19154@ics.muni.cz>
	 <4B9021EF.60309@oracle.com> <20100304212149.GM19154@ics.muni.cz>
	 <4B903485.1030608@oracle.com> <20100304224011.GN19154@ics.muni.cz>
	 <20100308101607.GR19154@ics.muni.cz>
	 <20100308070209.7cabb55f@tlielax.poochiereds.net>
	 <20100308121117.GW19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: Jeff Layton <jlayton@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:38539 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab0CHNoK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 08:44:10 -0500
Received: by bwz1 with SMTP id 1so2788831bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 08 Mar 2010 05:44:08 -0800 (PST)
In-Reply-To: <20100308121117.GW19154@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/3/8 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> On Mon, Mar 08, 2010 at 07:02:09AM -0500, Jeff Layton wrote:
>> (cc'ing Olga)
>>
>> Hmm....gssd in 1.2.2 seems to work fine for me. The only changes in
>> that area of the code were some of Olga's patches that went into 1.2=
=2E2.
>> Olga, any thoughts?
>
> It does not work for me and for one student that works on some patche=
s.
>
> We both have an issue with compilation as well as I mentioned earlier=
=2E
>
>> Lukas, could you also tell us what kernel you're using, and maybe se=
nd
>> the output of ldd against the binary?
>
> My kernel is 2.6.33. The student's kernel is about 2.6.31 or 2.6.32.
>
> ldd /tmp/nfs-utils-1.2.2/utils/gssd/gssd
> =A0 =A0 =A0 =A0linux-vdso.so.1 =3D> =A0(0x00007fff317ed000)
> =A0 =A0 =A0 =A0libgssapi_krb5.so.2 =3D> /usr/lib/libgssapi_krb5.so.2 =
(0x00007faa7c631000)
> =A0 =A0 =A0 =A0libkrb5.so.3 =3D> /usr/lib/libkrb5.so.3 (0x00007faa7c3=
6d000)
> =A0 =A0 =A0 =A0libk5crypto.so.3 =3D> /usr/lib/libk5crypto.so.3 (0x000=
07faa7c146000)
> =A0 =A0 =A0 =A0libcom_err.so.2 =3D> /lib/libcom_err.so.2 (0x00007faa7=
bf42000)
> =A0 =A0 =A0 =A0librpcsecgss.so.3 =3D> /usr/lib/librpcsecgss.so.3 (0x0=
0007faa7bd32000)
> =A0 =A0 =A0 =A0libgssglue.so.1 =3D> /usr/lib/libgssglue.so.1 (0x00007=
faa7bb27000)
> =A0 =A0 =A0 =A0libdl.so.2 =3D> /lib/libdl.so.2 (0x00007faa7b923000)
> =A0 =A0 =A0 =A0libc.so.6 =3D> /lib/libc.so.6 (0x00007faa7b5a2000)
> =A0 =A0 =A0 =A0libkrb5support.so.0 =3D> /usr/lib/libkrb5support.so.0 =
(0x00007faa7b399000)
> =A0 =A0 =A0 =A0libkeyutils.so.1 =3D> /lib/libkeyutils.so.1 (0x00007fa=
a7b196000)
> =A0 =A0 =A0 =A0libresolv.so.2 =3D> /lib/libresolv.so.2 (0x00007faa7af=
7d000)
> =A0 =A0 =A0 =A0libpthread.so.0 =3D> /lib/libpthread.so.0 (0x00007faa7=
ad5f000)
> =A0 =A0 =A0 =A0/lib64/ld-linux-x86-64.so.2 (0x00007faa7c886000)
>
> The student uses Debian, I use Ubuntu (so similar distros).
>
> Package =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0version
> ----------------------------------------------
> libgssapi-krb5-2 =A0 =A0 =A0 =A0 =A0 =A0 1.8+dfsg~alpha1-7
> libkrb5-3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01.8+dfsg~alpha1-7
> libk5crypto3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1.8+dfsg~alpha1-7
> libcomerr2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1.41.10-1ubuntu2
> librpcsecgss3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00.19-2
> libgssglue1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00.1-4
> libc6 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02.11.1-0ubuntu4
> libkrb5support0 =A0 =A0 =A0 =A0 =A0 =A0 =A01.8+dfsg~alpha1-7
> libkeyutils1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1.2-12
>
> --
> Luk=E1=B9 Hejtm=E1nek

I don't know how much testing has been done with nfs-utils and krb5
1.8.  Debian is usually the first to hit (and correct) any problems.
Is there a later kerberos release you could try?  The final version of
krb5 1.8 was released last week.

K.C.
