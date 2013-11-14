Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:45863 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811Ab3KNQrH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 11:47:07 -0500
Received: by mail-ie0-f181.google.com with SMTP id tp5so2940029ieb.40
        for <linux-nfs@vger.kernel.org>; Thu, 14 Nov 2013 08:47:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1384371057-16454-1-git-send-email-bjschuma@netapp.com>
References: <1384371057-16454-1-git-send-email-bjschuma@netapp.com>
Date: Thu, 14 Nov 2013 17:47:06 +0100
Message-ID: <CALXu0UfQuj+BNntibGf3CXcBnbP0pHTnZ5-Rp6FAwhfeNxjoow@mail.gmail.com>
Subject: Re: [PATCH v3 0/3] NFSD: Implement SEEK
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13 November 2013 20:30, Anna Schumaker <bjschuma@netapp.com> wrote:
> These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS is
> still under discussion with the IETF after my last series of patches, so I
> am holding off on resubmitting until after spec discussion dies down.
>
> Questions?  Comments?  Thoughts?
> Anna

1. Doesn't SEEK_HOLE/SEEK_DATA already work in NFSv4? I always had the
impression this worked there...

2. Does http://svn.nrubsig.org/svn/people/gisburn/code/sparsefiles/lsholes.c
work with your changes (the name is unfortunate, but its useful to
list the holes in a file and even has a short test)?

3. If you implement SEEK_HOLE/SEEK_DATA support you have to alter
fpathconf() support and implement the _PC_MIN_HOLE_SIZE properly.

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
