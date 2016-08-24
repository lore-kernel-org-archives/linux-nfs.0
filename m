Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:32533 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754891AbcHXSXl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2016 14:23:41 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Lever Chuck <chuck.lever@oracle.com>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: READ during state recovery uses zero stateid
Date: Wed, 24 Aug 2016 18:23:27 +0000
Message-ID: <87A94B50-A9D5-44FF-9F78-F916C98E6767@primarydata.com>
References: <AB29A5B8-1564-4C31-A843-F0C5CC4C91F1@oracle.com>
In-Reply-To: <AB29A5B8-1564-4C31-A843-F0C5CC4C91F1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 24, 2016, at 14:10, Chuck Lever <chuck.lever@oracle.com> wrote:
>=20
> Hi-
>=20
> I have a wire capture that shows this race while a simple I/O workload is
> running:
>=20
> 0. The client reconnects after a network partition
> 1. The client sends a couple of READ requests
> 2. The client independently discovers its lease has expired
> 3. The client establishes a fresh lease
> 4. The client destroys open, lock, and delegation stateids for the file
> that was open under the previous lease
> 5. The client issues a new OPEN to recover state for that file
> 6. The server replies to the READs in step 1. with NFS4ERR_EXPIRED
> 7. The client turns the READs around immediately using the current open
> stateid for that file, which is the zero stateid
> 8. The server replies NFS4_OK to the OPEN from step 5
>=20
> If I understand the code correctly, if the server happened to send those
> READ replies after its OPEN reply (rather than before), the client would
> have used the recovered open stateid instead of the zero stateid when
> resending the READ requests.
>=20
> Would it be better if the client recognized there is state recovery in
> progress, and then waited for recovery to complete, before retrying the
> READs?
>=20

Why isn=92t the session draining taking care of ensuring the READs don=92t =
happen until after recovery is done?

