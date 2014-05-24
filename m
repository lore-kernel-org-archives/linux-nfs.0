Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f47.google.com ([74.125.82.47]:39291 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbaEXAm3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 20:42:29 -0400
Received: by mail-wg0-f47.google.com with SMTP id x12so5367375wgg.18
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 17:42:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53563F16.80809@fastmail.fm>
References: <lis0kj$kaj$1@ger.gmane.org>
	<53548EF2.40408@gmail.com>
	<53563F16.80809@fastmail.fm>
Date: Sat, 24 May 2014 08:42:27 +0800
Message-ID: <CAB6yy355GCkjO8u0SVTUEUMJfTUjydNsEB87pwJG2h13T4uWKw@mail.gmail.com>
Subject: Re: [PATCH] nfsd: nfsd4_decode_create: Fix a possible NULL pointer dereference
From: Kinglong Mee <kinglongmee@gmail.com>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 22, 2014 at 6:06 PM, Bernd Schubert
<bernd.schubert@fastmail.fm> wrote:
>
>> cr_linkname maybe a path contains '/', or '.',
>> check_filename will return error nfserr_badname for those path.
>>
>> IMO, just check whether the length is zero as,
>>
>> if (create->cr_linklen == 0)
>>     return nfserr_inval;
>>
> Hmm, right, checking for a '/' not right here. Checking if link-name is
> "." or ".." isn't required, but shouldn't hurt either. But on the other
> hand we can leave that to the underlying file system.

According to rfc3530, 14.2.9, DESCRIPTION

   If the newname has a length of 0 (zero), or if newname does not obey
   the UTF-8 definition, the error NFS4ERR_INVAL will be returned.

The underlying filesystem will return -ENOENT not -EINVAL.
So, NFSD needs checking it explicitly by-self.

Can you sent the patch of v2?

thanks,
Kinglong Mee
