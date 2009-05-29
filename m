Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:48081 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbZE2Sgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 14:36:47 -0400
Subject: Re: New file doesn't show up if cached as missing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090529175243.GA30961@hostway.ca>
References: <20090529175243.GA30961@hostway.ca>
Content-Type: text/plain
Date: Fri, 29 May 2009 14:36:46 -0400
Message-Id: <1243622206.7155.103.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-05-29 at 10:52 -0700, Simon Kirby wrote:
> Hello!
> 
> On Linux 2.6.28.10 server and client, with NFSv3 or NFSv4, I can
> fairly easily reproduce a case where creating a file (open,write,close)
> and then attempting to open it on another client mounting the same server
> returns ENOENT.  If I run "ls" before I try to cat it, it works.
> 
> To reproduce:
> 
> ssh root@lps01 'rm -f /shared/ssl/test; stat /shared/ssl/test'; \
> ssh root@lps02 'echo hi > /shared/ssl/test'; \
> ssh root@lps01 'cat /shared/ssl/test'
> 
> The original stat (or cat or open) is important as it seems to cache that
> the file does not exist.  I can then even log in and poke around:
> 
> lps01:~# cd /shared
> lps01:/shared# cat test
> cat: test: No such file or directory
> lps01:/shared# stat test
> stat: cannot stat `test': No such file or directory
> lps01:/shared# ls test
> ls: test: No such file or directory
> lps01:/shared# ls
> <files including "test">
> lps01lsh:/shared# cat test
> hi
> 
> Is this expected behaviour?  The file system is mounted on both clients
> with: rw,hard,intr,...,acdirmin=0,acdirmax=0,acregmin=0,acregmax=0,noac
> 
> (eg: we can't find a way to make it not happen.)

That is most likely to be a consequence of poor mtime resolution on the
server (i.e. the directory mtime failing to change because the file
creation occurred within < 1 second of the 'rm'), combined with negative
lookup caching.

Try using the '-olookupcache=positive' or '-olookupcache=none' mount
options (requires a relatively recent version of nfs-utils).

Trond

