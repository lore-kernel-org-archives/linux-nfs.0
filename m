Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:53093 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750707AbdAXTMf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:12:35 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: handling error on RECLAIM_COMPLETE
Date: Tue, 24 Jan 2017 19:12:27 +0000
Message-ID: <35619FC0-AD46-4BBA-9F5B-9C89364BAF82@primarydata.com>
References: <CAN-5tyF+Uth87mnmWC2UaRU134whqNG8gEyNHBR_hOu9OYSZuw@mail.gmail.com>
In-Reply-To: <CAN-5tyF+Uth87mnmWC2UaRU134whqNG8gEyNHBR_hOu9OYSZuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 24, 2017, at 14:06, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> Hi Trond,
>=20
> Is there a reason that nfs4_proc_reclaim_complete() isn't  wrapped
> with a do while() to handle errors?

What do we not already handle correctly in nfs4_reclaim_complete_done()?

