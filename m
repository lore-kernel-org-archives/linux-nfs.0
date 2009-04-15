From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Exposing cache statistics
Date: Wed, 15 Apr 2009 16:41:32 -0400
Message-ID: <1239828092.5177.139.camel@heimdal.trondhjem.org>
References: <49E643CD.9070809@disney.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:54561 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbZDOUlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2009 16:41:36 -0400
In-Reply-To: <49E643CD.9070809-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-04-15 at 13:30 -0700, Kevin Constantine wrote:
> Has there been any effort to expose caching statistics to the end user? 
>   On the client-side, it would be useful to see how much data is being 
> re-used from cache vs data that gets retrieved over the wire.  Similarly 
> on the server side, it would be nice to see how much data is being 
> served from cache vs having to pull the data from disk.
> 
> Just wondering if anyone started anything to expose this sort of 
> information.

See the nfs-iostat tool in the nfs-utils package:

   http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=tree;f=tools/nfs-iostat;h=929e303cc762a68dfd01546f5150eb294274164e;hb=refs/heads/master

Note that you need a 2.6.17 kernel or newer.

Cheers
  Trond

