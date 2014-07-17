Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:50564 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbaGQFAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 01:00:09 -0400
Received: by mail-vc0-f178.google.com with SMTP id la4so3540091vcb.23
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 22:00:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140716193838.GD2397@fieldses.org>
References: <20140716193838.GD2397@fieldses.org>
Date: Wed, 16 Jul 2014 22:00:08 -0700
Message-ID: <CAHQdGtRUq0zVB-QM+Z9WpsOTa=py0Ba+YKghZwmr5rbD3RdBeA@mail.gmail.com>
Subject: Re: invalidating cache on chmod
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 12:38 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> As of (a backport of) 3a1556e8662 "NFSv2/v3: Simulate the change
> attribute" we have a user complaining about chmod on the client
> invalidating data caches.  (They have some sort of pipeline running on
> the client where output from one stage is has ownership and permissions,
> but not data, change before being used as input to the next.)
>
> Looks like that's expected?

Yes, that's expected. There is a tradeoff here: we could either use
the ctime, in which case there is the problem of false negative cache
revalidations (in cases such as the above), or we could use the mtime,
which has a problem of false positive cache revalidations (after an
application deliberately sets the mtime value).

The choice fell on ctime because that's what was being used for NFSv4
and, because false positive revalidations can lead to data corruption,
whereas false negatives do not.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
