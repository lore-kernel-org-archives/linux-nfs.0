Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:39127 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933488AbdGSPhL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 11:37:11 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 127DE280372
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 17:37:09 +0200 (CEST)
Date: Wed, 19 Jul 2017 17:37:07 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1254170191.4396985.1500478627748.JavaMail.zimbra@desy.de>
In-Reply-To: <1500474799.83884.1.camel@primarydata.com>
References: <1535638152.4367330.1500472704645.JavaMail.zimbra@desy.de> <CAN-5tyHecetnWKWiCbHfLWZ1REE+nyVoBQk9+VQ3QQO2jquraw@mail.gmail.com> <1500474799.83884.1.camel@primarydata.com>
Subject: Re: SETATTR without stateid
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Ok, Thanks for clarification. I probably misread some sentences like:

   A valid stateid SHOULD always be specified.  When the file size
   attribute is not set, the special anonymous stateid MAY be passed.

anyway, it's I have to handle it on the server as RHEL6 clients won't get
any new updates.

Tigran.
----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "Olga Kornievskaia" <a=
glo@umich.edu>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Wednesday, July 19, 2017 4:33:27 PM
> Subject: Re: SETATTR without stateid

> On Wed, 2017-07-19 at 10:22 -0400, Olga Kornievskaia wrote:
>> On Wed, Jul 19, 2017 at 9:58 AM, Mkrtchyan, Tigran
>> <tigran.mkrtchyan@desy.de> wrote:
>> > Dear friends,
>> >=20
>> > By running xfstest (generic/013) I have discovered client side
>> > misbehavior.
>> > Consider the following test code:
>> >=20
>> > -----
>> >=20
>> > #include <stdio.h>
>> > #include <stdlib.h>
>> > #include <unistd.h>
>> > #include <fcntl.h>
>> >=20
>> >=20
>> > int main(int argc, char **argv)
>> > {
>> >=20
>> >   if (argc !=3D 2) {
>> >     fprintf(stderr, "Usage: %s <path>\n", argv[0]);
>> >     exit(1);
>> >   }
>> >=20
>> >   int rc =3D truncate(argv[1], 8192);
>> >   if (rc < 0) {
>> >     perror("Failed to truncate the file");
>> >     exit(4);
>> >   }
>> >   exit(0);
>> > }
>> >=20
>> >=20
>> > ----
>> >=20
>> > The expectation is that client will send a valid open stateid with
>> > SETATTR (rfc7530#16.32.4).
>> > However, this is not the case - client just send's a SETATTR with
>> > size, but without any open.
>>=20
>> SETATTR is allowed to send an all-zero stateid:
>>=20
>> RFC7530 9.1.4.3
>>=20
>> Anonymous Stateid:  When "other" and seqid are both zero, the stateid
>>       is treated as a special anonymous stateid, which can be used in
>>       READ, WRITE, and SETATTR requests to indicate the absence of
>> any
>>       open state associated with the request.
>=20
> Agreed. As Olga says, there is no spec requirement that the client open
> the file in order to service a truncate() call, so this behaviour is by
> design.
>=20
> Cheers
>  Trond
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=BF=
=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=BF=
=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD{=EF=BF=BD=EF=BF=
=BD=EF=BF=BD"=EF=BF=BD=EF=BF=BD^n=EF=BF=BDr=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=
=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD&=EF=BF=BD=EF=
=BF=BD=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD(=EF=BF=BD=E9=9A=8E=EF=
=BF=BD=DD=A2j"=EF=BF=BD=EF=BF=BD=EF=BF=BDm=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD=EF=BF=BDf=EF=BF=BD=EF=BF=BD=
=EF=BF=BDh=EF=BF=BD=EF=BF=BD=EF=BF=BD~=EF=BF=BDm=EF=BF=BD
