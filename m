Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F4C9C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 21:25:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DD29020840
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 21:25:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=samba.org header.i=@samba.org header.b="qk3u+YJr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726180AbfCFVZX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 16:25:23 -0500
Received: from hr2.samba.org ([144.76.82.148]:30030 "EHLO hr2.samba.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725747AbfCFVZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 16:25:23 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=samba.org;
         s=42627210; h=To:Message-Id:Cc:Date:From;
        bh=C88aomQa80sJ+cxPn6UcZPrw72UBno5a7zCoJqHzqcc=; b=qk3u+YJrCxvMEkOWJnE5rFhZ8K
        HtYPEEW3Jns/iHDXkT64hs69llqnmQ/kfxxKWZstK4Pb3mEnqcTm8e8jSuhu8jjMUPA5Y+j4s7iH6
        +UAjK5Hc5B+3wsrfdiTYcBRkiTfvh3MlhvBDPH7s0vHefIUPCgUWB31/n3uwGpxLGMM4=;
Received: from [127.0.0.2] (localhost [127.0.0.1])
        by hr2.samba.org with esmtpsa (TLS1.2:ECDHE_ECDSA_AES_256_GCM_SHA384:256)
        (Exim)
        id 1h1e2S-0001ka-Gd; Wed, 06 Mar 2019 21:25:20 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: Better interop for NFS/SMB file share mode/reservation
From:   =?utf-8?Q?Ralph_B=C3=B6hme?= <slow@samba.org>
In-Reply-To: <20190306210743.GE19279@jra3>
Date:   Wed, 6 Mar 2019 22:25:18 +0100
Cc:     Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, devel@lists.nfs-ganesha.org,
        Amir Goldstein <amir73il@gmail.com>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F00A0481-0AC7-411E-8353-BF104713F524@samba.org>
References: <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3>
 <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
 <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org>
 <20190306151150.GC2426@fieldses.org>
 <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
 <20190306210743.GE19279@jra3>
To:     Jeremy Allison <jra@samba.org>
X-Mailer: Apple Mail (2.3445.102.3)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Jeremy Allison wrote:
> On Wed, Mar 06, 2019 at 03:31:08PM -0500, Jeff Layton wrote:
>> On Wed, 2019-03-06 at 10:11 -0500, J. Bruce Fields wrote:
>>>=20
>>> Jeff, wasn't there some work (on Ceph maybe?) on a userspace =
delegation
>>> API?  Is that close to what's needed?
>>>=20
>>=20
>> Here's the C headers for that stuff:
>>=20
>>    =
https://github.com/ceph/ceph/blob/7ba6bece4187eda5d05a9b84211fe6ba8dd287bd=
/src/include/cephfs/libcephfs.h#L1734
>>=20
>> It's simple enough and works for us in ganesha, and I think we can
>> probably adapt it to samba without too much difficulty. The callback
>> doesn't seem like it'll do for a kernel API though -- you'd almost
>> certainly need to do something different there (signals? inotify?).
>=20
> SMB3 leases have R/RW and Handle-based leases.

Just to be precise: SMB2.1+ has R, RH, RW and RWH leases.

> Handle leases allow multiple opens of the same pathname
> that get different handles to share the lease, allowing
> a client redirector to delay opens or closes locally
> so long as it has a handle lease.

That'a a propertly of leases in general, not just H-leases. The client =
provides a lease key which is a GUID with each lease request

>=20
> Here are the semantics:
>=20
> =
https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/d8df9=
43d-6ad7-4b30-9f58-96ae90fc6204
>=20
> I'm not sure a simple file-descriptor based API is
> enough for us. Can he have a uuid or token based
> API instead where the server can chose what fd's
> to cover with a token ?

Yes, that would be ideal.

-slow
