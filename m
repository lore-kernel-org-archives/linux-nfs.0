From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 14:21:57 -0500
Message-ID: <4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
References: <4B7D4E55.4040002@RedHat.com> <4B9021EF.60309@oracle.com>
	 <20100304212149.GM19154@ics.muni.cz> <4B903485.1030608@oracle.com>
	 <20100304224011.GN19154@ics.muni.cz>
	 <20100308101607.GR19154@ics.muni.cz>
	 <20100308070209.7cabb55f@tlielax.poochiereds.net>
	 <20100308121117.GW19154@ics.muni.cz>
	 <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	 <20100308153042.GB19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:38209 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753576Ab0CHTV7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 14:21:59 -0500
Received: by bwz1 with SMTP id 1so3144458bwz.21
        for <linux-nfs@vger.kernel.org>; Mon, 08 Mar 2010 11:21:58 -0800 (PST)
In-Reply-To: <20100308153042.GB19154@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/3/8 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> On Mon, Mar 08, 2010 at 08:44:07AM -0500, Kevin Coffman wrote:
>> I don't know how much testing has been done with nfs-utils and krb5
>> 1.8. =A0Debian is usually the first to hit (and correct) any problem=
s.
>> Is there a later kerberos release you could try? =A0The final versio=
n of
>> krb5 1.8 was released last week.
>
> looks like some error check has been removed since nfs-utils 1.2.0. r=
pc.gssd
> from nfs-utils 1.2.0 complains with:
>
> Mar =A08 16:28:20 anubis rpc.gssd[1982]: rpcsec_gss: gss_init_sec_con=
text:
> (major) Unspecified GSS failure. =A0Minor code may provide more infor=
mation
> - (minor) No supported encryption types (config file error?)
>
> rpc.gssd from 1.2.2 segfaults.

Are you aware that DES is disabled by default with krb5 1.8?  See
http://www.mit.edu/~kerberos/krb5-1.8/

So you probably need to add "allow_weak_crypto =3D true" to your
/etc/krb5.conf file.  (I believe MIT added an API to allow this
programmatically, but I haven't been following closely enough.)

That doesn't excuse the segfault in 1.2.2 though.

K.C.
