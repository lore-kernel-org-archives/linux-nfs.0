From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Tue, 9 Mar 2010 13:26:14 -0500
Message-ID: <4d569c331003091026r7e83523bwb8c448edf90441ed@mail.gmail.com>
References: <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	 <4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	 <20100308194054.GC19154@ics.muni.cz>
	 <20100308144825.0e1afa59@tlielax.poochiereds.net>
	 <20100309103548.GJ19154@ics.muni.cz>
	 <4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
	 <20100309155310.GR19154@ics.muni.cz>
	 <4d569c331003090904i3eca4b93h1bce760e72bac370@mail.gmail.com>
	 <20100309172908.GU19154@ics.muni.cz>
	 <20100309174159.GW19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:53751 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363Ab0CIS0Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 13:26:16 -0500
Received: by bwz1 with SMTP id 1so4179284bwz.21
        for <linux-nfs@vger.kernel.org>; Tue, 09 Mar 2010 10:26:14 -0800 (PST)
In-Reply-To: <20100309174159.GW19154@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/3/9 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> On Tue, Mar 09, 2010 at 06:29:08PM +0100, Lukas Hejtmanek wrote:
>> But I found the problem. They are still autotools which are failing. Something
>> adds -lgssapi_krb5 into KRBLIBS. If I remove -lgssapi_krb5 and use -lgssglue
>> instead, it runs fine.
>
> this seems to be caused by configure, which contains:
> KRBLIBS=`$K5CONFIG --libs gssapi`
>
> $ krb5-config --libs gssapi
> -Wl,-Bsymbolic-functions -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err
>
> ./aclocal/kerberos5.m4 contains as well:
> KRBLIBS=`$K5CONFIG --libs gssapi`

Yes, but the utils/gssd/Makefile should link librpcsecgss and
libgssglue before the Kerberos libs.

(We need the krb5 libs to deal with credential cache and keytab stuff directly.)
