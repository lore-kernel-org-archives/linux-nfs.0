Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34203 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933132AbcFHVvZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 17:51:25 -0400
Received: by mail-oi0-f65.google.com with SMTP id r4so4164623oib.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2016 14:51:24 -0700 (PDT)
Subject: Re: [PATCH] Fix NFS option parsing bit-rot.
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <57560021.5030708@landley.net>
 <B4B27507-DD34-49D0-9BE9-01C9DA1A86FA@primarydata.com>
 <575874E5.3070809@landley.net>
 <615FD41F-9C7D-4BAA-8BC5-D1F3CA115A8E@primarydata.com>
From: Rob Landley <rob@landley.net>
Message-ID: <57589359.5020507@landley.net>
Date: Wed, 8 Jun 2016 16:51:21 -0500
In-Reply-To: <615FD41F-9C7D-4BAA-8BC5-D1F3CA115A8E@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/08/2016 03:35 PM, Trond Myklebust wrote:
>=20
>=20
> On 6/8/16, 15:41, "Rob Landley" <rob@landley.net> wrote:
>>So addr=3D is at _best_ redundant. You MUST supply host:/ always,
>>the current code just wasn't using it.
>=20
> That=E2=80=99s because you just happen to be supplying an IP address inst=
ead of
> a hostname. The kernel has no DNS resolving functionality. It cannot
> resolve hostnames into IP addresses without help either by the caller or
> by means of an upcall. That is why =E2=80=98addr=3D=E2=80=99 has been a m=
andatory
> parameter ever since we introduced the text based parser.

Then why is host: mandatory in the dev name?

Rob
