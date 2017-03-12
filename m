Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:48116 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755675AbdCLSky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 12 Mar 2017 14:40:54 -0400
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1] PNFS dont retry some error when MDS=DS
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <1489247175.3260.5.camel@primarydata.com>
Date: Sun, 12 Mar 2017 14:40:49 -0400
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <A6FAD06E-0F4F-405E-871B-751E763BACB9@netapp.com>
References: <CAN-5tyEe9txY5CmcZLOE4du=modRSaxKm8uLLT44YtKmSgAOgg@mail.gmail.com>
 <20170310213715.38258-1-kolga@netapp.com>
 <1489247175.3260.5.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 11, 2017, at 10:46 AM, Trond Myklebust =
<trondmy@primarydata.com> wrote:
>=20
> On Fri, 2017-03-10 at 16:37 -0500, Olga Kornievskaia wrote:
>> If we sent an operation to the "DS" and got an error, the code
>> resends
>> to "MDS" but when they are the same, it gets the same error and goes
>> into the infinite loop. Example was COMMIT getting EACCES.
>>=20
>=20
> The correct behaviour when getting EACCES from a COMMIT to the MDS
> would be to retry the entire series of WRITE calls with stable writes.
> If the server then returns with anything other than FILE_SYNC, then
> EIO.
>=20
> Why is the server failing the COMMIT here if the client thinks it sent
> unstable writes?

This looping was discovered during connectathon testing against the desy =
server. While I believe Tigran thinks there is an error in his code and =
EACCES from COMMIT was unexpected, we thought that it would be best if =
the client didn=E2=80=99t go into infinite loop in this condition given =
that EACCES is a valid error for COMMIT. If you think this shouldn=E2=80=99=
t happen in real life, then I=E2=80=99m ok with not pursuing this.=20

On a different but related note, in case when MDS !=3D DS, when the =
writes are retried they are not retried against the MDS but again are =
sent to the DS, is that a bug?

>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

