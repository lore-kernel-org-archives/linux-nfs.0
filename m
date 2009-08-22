From: Stefan Egli <stefan.egli@gmail.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Sun, 23 Aug 2009 01:28:35 +0200
Message-ID: <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <1250962724.8143.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50372 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933248AbZHVX2e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Aug 2009 19:28:34 -0400
Received: by bwz19 with SMTP id 19so956386bwz.37
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2009 16:28:35 -0700 (PDT)
In-Reply-To: <1250962724.8143.29.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> No directory _attribute_ caching, which again should mean that we check
> if the parent directory mtime has changed on each lookup.

Ok, sorry for not doing a complete RTFM but is there an attribute then for
disabling directory caching?

> The restore will probably mess with the mtime, in which case you should
> probably apply the above commit (applications cannot change the ctime).

The odd thing is, that we're seeing sync delays of up to 4-5 hours when
doing a restore onto NFS, but also 1-2 hours when doing a backup from
NFS (which is then only reads) - the latter is rather odd as in making cache
syncs that slow, isn't it? Looks like an overload situation maybe?

Cheers,
Stefan
