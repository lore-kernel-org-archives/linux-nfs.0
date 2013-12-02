Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:61610 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab3LBO1U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 09:27:20 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so20782516ieb.18
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 06:27:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5B7CDA5C-C3F1-4CFD-9A72-013523068FBB@primarydata.com>
References: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
	<5B7CDA5C-C3F1-4CFD-9A72-013523068FBB@primarydata.com>
Date: Mon, 2 Dec 2013 15:27:20 +0100
Message-ID: <CAHnbEG+cJGjx7o=+ZASNo7ddc0O9hYG4fE0EAQ2hoh688nBBeQ@mail.gmail.com>
Subject: Re: Linux client access to NFSv4 Alternate Data Streams (O_XATTR)?
From: Sebastian Feld <sebastian.n.feld@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Joshuah Hurst <joshhurst@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 2, 2013 at 2:29 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
> On Dec 2, 2013, at 7:13, Joshuah Hurst <joshhurst@gmail.com> wrote:
>
>> We need to access NFSv4 Alternate Data Streams (what Solaris,
>> NexentaOS, Omnios and SmartOS can openat() with the O_XATTR flag) from
>> a (Suse) Linux client.
>>
>> OS is Suse Linux 12.3, x86-64, 64bit
>>
>> Does anyone know how to archive this?
>
> Why can’t you access Solaris-specific extensions from a Solaris client?

This isn't a Solaris-specific extension, its part of the original Sun
NFSv4 spec. Unfortunately the ARC/ARchitecture Cases from
Opensolaris.org are no longer available, otherwise the background,
e.g. feature parity with CIFS/NTFS, and the overall usefulness of such
a feature, would be clearer.

There are many many applications coming from either the Windows world
or the HPC camp (like nih.org or GE Healthcare) who mandatory rely on
the existence of this feature (well, at least enough so that AT&T
cloud services and the related toolchain (e.g. AST, including ksh93)
now have extensive support for O_XATTR).

Sebastian
