Return-Path: ffilzlnx@mindspring.com
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Boaz Harrosh'" <ooo@electrozaur.com>,
        "'Anna Schumaker'" <Anna.Schumaker@netapp.com>,
        "'Benjamin Coddington'" <bcodding@redhat.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com> <alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com> <54622ADF.4080807@Netapp.com> <546238D9.2030804@electrozaur.com>
In-Reply-To: <546238D9.2030804@electrozaur.com>
Subject: RE: mount default minor version behavior
Date: Tue, 11 Nov 2014 11:19:40 -0800
Message-ID: <00ea01cffde4$71c65d70$55531850$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
List-ID: <linux-nfs.vger.kernel.org>

> > I don't think so. Right now users know that if they don't use a =
minor
> > version then they'll be getting a v4.0 mount. I think we should keep
> > this behavior so we don't accidentally break people's configuration.
> >
>=20
> This would be inconsistent and there for unexpected.
>=20
> What you suggest is:
> * if user specifies no version then start with 4.1, work down to =
supported
> version
> * if user specifies major=3D4 only try 4.0
> * if user specifies major.minor only try major.minor
>=20
> I think a more expect behavior would be:
> * if user specifies no version then start with 4.1, work down to =
supported
> version
> * if user specifies major=3D4 start with 4.1 til 4.0
> * if user specifies major.minor only try major.minor
>=20
> The preferred (implicit) minor is 1 in all cases
>=20
> The question is did users of major=3D4 meant 4.0 and were lazy to type =
".0"
> or did they mean "don't try 3 or 2"

Have we always allowed specifying 4.0? Or was there a time when you =
could only specify 4 (meaning 4.0)?

If the latter, then backwards compatibility suggests 4 should mean 4.0.

> Current system compatibility is already changing by moving all case 1 =
above
> from 4.0 to 4.1 by the next yum update. I think it would be reasonable =
to also
> change case 2. And have a consistent semantics.

Frank
