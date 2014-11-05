Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f175.google.com ([209.85.212.175]:52478 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbaKEUGt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 15:06:49 -0500
Received: by mail-wi0-f175.google.com with SMTP id ex7so13502689wid.14
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2014 12:06:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141105144251.725816f6@tlielax.poochiereds.net>
References: <CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com>
	<CAHQdGtRuWdHBPfBzCTmDwsYXtpqNSwpGUdtoUqs3jWAd2unxEQ@mail.gmail.com>
	<CAN-5tyGUxgjpcb2=jnQQOD60ernNzf1YSnTG8B-NXUP5OidEFw@mail.gmail.com>
	<CAHQdGtQ=RBoO1u_7501-G2rbDEGim5Hh2G6zuWyyLVVy8QAQWw@mail.gmail.com>
	<CAHQdGtRo2uw5U1-w9O2U=4C8BwxCECAjjeC9SCdkyEP8FQ94Gw@mail.gmail.com>
	<CAN-5tyGsopFNFjo=LBwYE9n6b7Emv73Rkw0H2wyq2vCjMUOftA@mail.gmail.com>
	<CAHQdGtSQJLe60ja+-ChkHXOu8_UjmOpd4X7QHyhNOj1mPQGWPg@mail.gmail.com>
	<20141105065719.23e912b1@tlielax.poochiereds.net>
	<CAABAsM4YWr2fuQYXVa7jCDKexYPML8C1B6y13XVBKO-psXUmOA@mail.gmail.com>
	<20141105183152.GB6513@fieldses.org>
	<20141105144251.725816f6@tlielax.poochiereds.net>
Date: Wed, 5 Nov 2014 15:06:48 -0500
Message-ID: <CAHQdGtSxoLwLn--9xjY7tKuTYjLL=R1Ezkp=5_-XzfUFgvtk2g@mail.gmail.com>
Subject: Re: how to properly handle failures during delegation recall process
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Thomas Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 5, 2014 at 2:42 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> On Wed, 5 Nov 2014 13:31:52 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> Oops, right, except for the case where the delegation's revoked just
>> because the client ran out of time doing the recall.  In which case I
>> think the final error's going to be either EXPIRED (4.0) or
>> DELEG_REVOKED (4.1)?  (Except I think the Linux server's returning
>> BAD_STATEID in the 4.0 case, which looks wrong.)
>>
>
> I'm not sure that that's right... RFC3530 says:
>
>    NFS4ERR_EXPIRED       A lease has expired that is being used in the
>                          current operation.
>
> ...implicit in the scenario I layed out above is that the lease is
> being maintained. It's just that the client failed to return the
> delegation in time. So, BAD_STATEID may be correct, actually?

NFS4ERR_ADMIN_REVOKED is the expected error, but that requires the
server to keep the stateid around for a while (which is why NFSv4.1
added the FREE_STATEID requirement). NFS4ERR_BAD_STATEID will work in
a pinch...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
