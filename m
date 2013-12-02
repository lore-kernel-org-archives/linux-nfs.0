Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:62975 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066Ab3LBT1X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 14:27:23 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so21184755ieb.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 11:27:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131202152102.GA20458@infradead.org>
References: <CAEEMktPamgjSHA_OmHj73ti5G01DcC_ykYb=-_bfOYqy4nW8BA@mail.gmail.com>
	<5B7CDA5C-C3F1-4CFD-9A72-013523068FBB@primarydata.com>
	<CAHnbEG+cJGjx7o=+ZASNo7ddc0O9hYG4fE0EAQ2hoh688nBBeQ@mail.gmail.com>
	<20131202152102.GA20458@infradead.org>
Date: Mon, 2 Dec 2013 20:27:22 +0100
Message-ID: <CALXu0Ufugu6F0fKA_azkjCt8Nat+y0g4QFGZkLXZeXqATUzV0Q@mail.gmail.com>
Subject: Re: Linux client access to NFSv4 Alternate Data Streams (O_XATTR)?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Sebastian Feld <sebastian.n.feld@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Joshuah Hurst <joshhurst@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2 December 2013 16:21, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Dec 02, 2013 at 03:27:20PM +0100, Sebastian Feld wrote:
>> This isn't a Solaris-specific extension, its part of the original Sun
>> NFSv4 spec. Unfortunately the ARC/ARchitecture Cases from
>> Opensolaris.org are no longer available, otherwise the background,
>> e.g. feature parity with CIFS/NTFS, and the overall usefulness of such
>> a feature, would be clearer.
>
> It's a dumb part of the spec, and Linux has no intent support pretty
> braindead file/directory mixups.  Just store all your separate streams
> in separate files, that's how it's implemented underneath anyway.

Please. Please do me the favour and not rule something out that way.
Please hear the arguments and have a discussion.

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
