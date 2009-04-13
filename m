From: Rince <rincebrain@gmail.com>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Mon, 13 Apr 2009 19:44:26 -0400
Message-ID: <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
	 <1239650202.16771.15.camel@heimdal.trondhjem.org>
	 <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f117.google.com ([209.85.221.117]:65087 "EHLO
	mail-qy0-f117.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbZDMXo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 19:44:28 -0400
In-Reply-To: <5da0588e0904131506k5c58e8ddob9bf38f61da6302a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 13, 2009 at 6:06 PM, Rince <rincebrain@gmail.com> wrote:
> Patch does not apply cleanly to 2.6.30-rc1. Working on this.

Okay, so I'm having trouble getting this to apply to anything at all.
I can see it requires a previous patch by Nick, but even in the thread
it's mentioned that it doesn't apply cleanly.

Is there a canonical form that I can apply somewhere?

- Rich

PS: I rather expect my report here to be the same as that Bugzilla
bug, since I filed it. :)
-- 

If we were meant to get up early, God would have created us with alarm clocks.
