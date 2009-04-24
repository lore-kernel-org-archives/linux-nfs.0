From: Rince <rincebrain@gmail.com>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Fri, 24 Apr 2009 05:26:28 -0400
Message-ID: <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
	 <1239650202.16771.15.camel@heimdal.trondhjem.org>
	 <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
	 <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f118.google.com ([209.85.221.118]:58173 "EHLO
	mail-qy0-f118.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbZDXJ0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 05:26:30 -0400
In-Reply-To: <5da0588e0904131644g131dc816r61884e83bc4cd006-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied try 3 of Nick Piggin's patch to 2.6.30-rc3 (cleanly, no less!)

Doesn't appear to have helped at all - I received my favorite BUG ON
write.c:252 just like always, within 24 hours of booting the kernel,
even.

- Rich
-- 

Keep out of reach of children.
