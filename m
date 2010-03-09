From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Tue, 9 Mar 2010 12:04:29 -0500
Message-ID: <4d569c331003090904i3eca4b93h1bce760e72bac370@mail.gmail.com>
References: <20100308101607.GR19154@ics.muni.cz>
	 <20100308121117.GW19154@ics.muni.cz>
	 <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	 <20100308153042.GB19154@ics.muni.cz>
	 <4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	 <20100308194054.GC19154@ics.muni.cz>
	 <20100308144825.0e1afa59@tlielax.poochiereds.net>
	 <20100309103548.GJ19154@ics.muni.cz>
	 <4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
	 <20100309155310.GR19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:33052 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab0CIREb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 12:04:31 -0500
Received: by bwz1 with SMTP id 1so4094640bwz.21
        for <linux-nfs@vger.kernel.org>; Tue, 09 Mar 2010 09:04:29 -0800 (PST)
In-Reply-To: <20100309155310.GR19154@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2010/3/9 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> On Tue, Mar 09, 2010 at 10:18:58AM -0500, Kevin Coffman wrote:
>> I've built nfs-utils with and without =A0--disable-tirpc and don't s=
ee
>> this problem.
>>
>> It could be a bug, but I would think that other [Debian and other]
>> testers would have already hit it.
>>
>> I'm concerned that perhaps your build issues may have somehow
>> introduced a [bad] mix of headers? =A0(i.e. were things built using =
the
>> libgssglue headers, or the Kerberos headers?)
>
> I have both. If I remove gssglue headers, it still faults. If I remov=
e
> kerberos headers, it does not even compile.
>
> I believe, that it has the following problem.
>
> gssd calls gss_acquire_cred, it calls the one from libgssapi_krb5.so.=
2.

I'm confused.  gssd shouldn't be calling any of the Kerberos GSS
functions directly, it should be calling the one in libgssglue, which
should call the mechanism-specific (Kerberos) version.

> This gss_acquire_cred filss in gss_union_cred_t structure.
> gssd calls gss_set_allowable_enctypes which is located in libgss_glue=
=2E
> The libgssglue uses gss_union_cred_t structure.
>
> This happens in limit_krb5_enctypes() in krb5_util.c
>
> Unfortunately, gss_union_cred_t in libgssglue is missing one (first) =
item
> compared to libgssapi_krb5.so.2, thus count is stored instead of mech=
s_array.
> The mechs_array contains value 1 as I have shown. Dereferrencing mean=
s
> segfault.
>
> Btw, do you have HAVE_SET_ALLOWABLE_ENCTYPES ?

Yes.
