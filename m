Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:55258 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbaLVQVZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Dec 2014 11:21:25 -0500
Received: by mail-vc0-f174.google.com with SMTP id id10so1780410vcb.33
        for <linux-nfs@vger.kernel.org>; Mon, 22 Dec 2014 08:21:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141221114015.GA25387@janus>
References: <20141221114015.GA25387@janus>
Date: Mon, 22 Dec 2014 11:21:24 -0500
Message-ID: <CAHQdGtSZmPKPAPyJ9K-aJDvnfjKEBsObx6MjxPgosOi1jKTuKQ@mail.gmail.com>
Subject: Re: 3.17.x 3.18.x nfs_permission(): put_rpccred() missing?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Frank,

On Sun, Dec 21, 2014 at 6:40 AM, Frank van Maarseveen
<frankvm@frankvm.com> wrote:
> While updating the nfs-ngroups patch for 3.17 and 3.18 I noticed that
> nfs_permission() seems to be missing a put_rpccred() call in the non
> -ECHILD path.

I fully agree that it is confusing, but the current code is actually
correct. Please see the changelog for commit bd95608053b7f
(sunrpc/auth: allow lockless (rcu) lookup of credential cache.) which
explains the rules for the RCU-safe credential lookup.

We definitely do want to document this behaviour  a little better in
the source. Any takers?

Cheers,
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
