Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:57109 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755426Ab0KCQYq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 12:24:46 -0400
Date: Wed, 3 Nov 2010 12:24:23 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andi Kleen <andi@firstfloor.org>, bjschuma@netapp.com,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [regression] NFS readdir change break fully cached nfs root
Message-ID: <20101103162423.GA3797@elliptictech.com>
References: <20101102180051.GA26089@basil.fritz.box>
 <1288731930.534.1.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1288731930.534.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-02 17:05 -0400, Trond Myklebust wrote:
> On Tue, 2010-11-02 at 19:00 +0100, Andi Kleen wrote:
> > My NFS root test systems stopped booting with 2.6.37-rc1. It just
> > hangs after entering user space.
[...]
> Does the following patch help?
[...]
> NFS: Fix a couple of regressions in readdir.

I just ran into this issue with git today, where some operations locked
up permanently (seemed to be an infinite readdir loop as described
elsewhere in this thread).

I applied this patch, and it solves the lockups, but there's a new
problem: the directory list sometimes comes back _empty_!

Here's the test script I used:

  #!/bin/sh -e
  
  mkdir gittest
  cd gittest
  git init
  
  for i in `seq 500`
  do
  	printf 'Hello\nWorld!\n' > $i.txt
  done
  
  git add ./*.txt
  git commit -m 'Initial Commit'
  sed -i 1d ./*.txt
  git stash
  git stash pop
  
  echo 'Directory listing:'
  ls

the 'ls' at the end prints nothing when the directory actually contains
500 files.  If we insert an 'ls' just before the 'git stash pop', that
one prints the full listing.  Touching the directory afterwards makes
the listings work again.

The script works fine on 2.6.36.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
