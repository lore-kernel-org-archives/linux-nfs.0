Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f175.google.com ([209.85.212.175]:49487 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932300AbaJUNM7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Oct 2014 09:12:59 -0400
Received: by mail-wi0-f175.google.com with SMTP id d1so10062376wiv.8
        for <linux-nfs@vger.kernel.org>; Tue, 21 Oct 2014 06:12:54 -0700 (PDT)
Message-ID: <54465BD2.7080900@electrozaur.com>
Date: Tue, 21 Oct 2014 16:12:50 +0300
From: Boaz Harrosh <ooo@electrozaur.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: xfstests generic/075 failure on recent Linus' tree
References: <20141020173658.GA7552@infradead.org>
In-Reply-To: <20141020173658.GA7552@infradead.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/20/2014 08:36 PM, Christoph Hellwig wrote:
> Running 4.1 against a same host server backed off XFS I run into
> a hang in generic/075:
> 
> generic/075 18s ...[  408.796877] nfs: server 127.0.0.1 not responding, still trying
> [  408.799131] nfs: server 127.0.0.1 not responding, still trying
> [  408.801357] nfs: server 127.0.0.1 not responding, still trying
> [  443.676971] nfs: server 127.0.0.1 not responding, timed out
> [  623.837009] nfs: server 127.0.0.1 not responding, timed out
> [  628.716855] nfs: server 127.0.0.1 not responding, timed out
> [  803.996883] nfs: server 127.0.0.1 not responding, timed out
> [  813.783542] nfs: server 127.0.0.1 not responding, timed out
> [  984.156873] nfs: server 127.0.0.1 not responding, timed out
> [  998.876901] nfs: server 127.0.0.1 not responding, timed out
> 
Sir Christoph

I'm not exactly sure about generic/075, I see it uses fsx. Might it be
a very heavy load of ltp/fsx ?

I'm asking because down the years I always had problems with localhost
(127.0.0.1 ?) mount, with oom conditions, specially when using a UML
or a tiny VM.

I know that for a long time it was not suppose to be tested, and
advertised as not supported. The explanation was because of the
way writeback works stacked FSs, and the upper layer FS consuming all
the allowed memory, not leaving any room for the lower layer FS to
do any writeback.

With the new writeback per BDI the situation was much much better
last I tried, but specially with NFS's lazy release of pages, I
still got a live lock in a tiny UML.
(So I'm not sure what is the official stand right now about local
 mount, am curious to know?)

But surly you should know all this, just that can you reproduce
the same problem with two VMs? It might shed some light?
(Also did you try to force the server to a sync IO, I wish NFSD
 could do true directIO from network buffers, but ...)

[Funny I'm having my own fights with fsx right now ;-)]

Thanks
Boaz

