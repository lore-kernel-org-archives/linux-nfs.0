Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl017-049-228.sfo4.dsl.speakeasy.net ([69.17.49.228]:34287
	"EHLO void.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873Ab1CaXEw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Mar 2011 19:04:52 -0400
To: Andrew Klaassen <clawsoon@yahoo.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: readdirplus/getattr
In-reply-to: <457901.56654.qm@web65410.mail.ac4.yahoo.com>
References: <457901.56654.qm@web65410.mail.ac4.yahoo.com>
Date: Thu, 31 Mar 2011 15:58:15 -0700
Message-ID: <23968.1301612295@risen.void.org>
From: Steven Procter <steven@void.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is due to client caching.  When the second ls -l runs the cache
contains an entry for the directory.  The client can check if the cached
directory data is still valid by issuing a GETATTR on the directory.

But this only validates the names, not the attributes, which are not
actually part of the directory.  Those must be refetched.  So the client
issues a GETATTR for each entry in the directory.  It issues them
sequentially, probably as ls calls readdir() and then stat()
sequentially on the directory entries.

This takes so long that the cache entry times out and the next time you
run ls -l the client reloads the directory using READDIRPLUS.

--Steven

> X-Mailer: YahooMailClassic/12.0.2 YahooMailWebService/0.8.109.295617
> Date:	Thu, 31 Mar 2011 15:24:15 -0700 (PDT)
> From:	Andrew Klaassen <clawsoon@yahoo.com>
> Subject: readdirplus/getattr
> To:	linux-nfs@vger.kernel.org
> Sender:	linux-nfs-owner@vger.kernel.org
> 
> Hi,
> 
> I've been trying to get my Linux NFS clients to be a little snappier about listing large directories from heavily-loaded servers.  I found the following fascinating behaviour (this is with 2.6.31.14-0.6-desktop, x86_64, from openSUSE 11.3, Solaris Express 11 NFS server):
> 
> With "ls -l --color=none" on a directory with 2500 files:
> 
>              |      rdirplus   |    nordirplus   |
>              |1st  |2nd  |1st  |1st  |2nd  |1st  |
>              |run  |run  |run  |run  |run  |run  |
>              |light|light|heavy|light|light|heavy|
>              |load |load |load |load |load |load |
> --------------------------------------------------
> readdir      |   0 |   0 |   0 |  25 |   0 |  25 |
> readdirplus  | 209 |   0 | 276 |   0 |   0 |   0 |
> lookup       |  16 |   0 |  10 |2316 |   0 |2473 |
> getattr      |   1 |2501 |2452 |   1 |2465 |   1 |
> 
> The most interesting case is with rdirplus specified as a mount option to a heavily loaded server.  The NFS client keeps switching back and forth between readdirplus and getattr:
> 
>  ~10 seconds doing ~70 readdirplus calls, followed by
>  ~150 seconds doing ~800 gettattr calls, followed by
>  ~12 seconds doing ~70 readdirplus calls, followed by
>  ~200 seconds doing ~800 gettattr calls, followed by
>  ~20 seconds doing ~130 readdirplus calls, followed by
>  ~220 seconds doing ~800 gettattr calls
> 
> All the calls appear to get reasonably prompt replies (never more than a second or so), which makes me wonder why it keeps switching back and forth between the strategies.  (Especially since I've specified rdirplus as a mount option.)
> 
> Is it supposed to do that?
> 
> I'd really like to see how it does with readdirplus ~only~, no getattr calls, since it's spending only 40 seconds in total on readdirplus calls compared to 570 seconds in total on (redundant, I think, based on the lightly-loaded case) getattr calls.
> 
> It'd also be nice to be able to force readdirplus calls instead of getattr calls for second and subsequent listings of a directory.
> 
> I saw a recent thread talking about readdirplus changes in 2.6.37, so I'll give that a try when I get a chance to see how it behaves.
> 
> Andrew
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
