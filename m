Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:54755 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965992AbcIWRpJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 13:45:09 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Kornievskaia Olga <aglo@umich.edu>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: reuse of slot and seq# when RPC was interrupted
Date: Fri, 23 Sep 2016 17:45:03 +0000
Message-ID: <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
In-Reply-To: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 23, 2016, at 13:40, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> If we instead bump the sequence number in the case of interrupted and do:

You have no guarantees that the server has seen and processed the operation=
.

