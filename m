Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41094 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754051AbcE1ARl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 20:17:41 -0400
MIME-Version: 1.0
Message-ID: <19769bfc-efc7-495f-9574-f771236a9765@default>
Date: Fri, 27 May 2016 17:17:29 -0700 (PDT)
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <torvalds@linux-foundation.org>
Cc: <trond.myklebust@primarydata.com>, <Anna.Schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.7
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- torvalds@linux-foundation.org wrote:

> On Fri, May 27, 2016 at 10:14 AM, Boris Ostrovsky
> <boris.ostrovsky@oracle.com> wrote:
> >
> > This breaks on older compilers:
> >
> >   CC      fs/nfs/nfs4state.o
> > /home/build/linux-linus/fs/nfs/nfs4state.c:69: error: unknown field
> > ‘data’ specified in initializer
> 
> Does the attached patch fix it for you?
> 
> I don't have easy access to the old compiler, but I _think_ the
> trivial patch of just adding braces around the data initializer
> should
> make old gcc's happy


It does fix it.

This is not the first time we've hit this and people have always been changing code to initialize fields in execution path (and I didn't fix it here myself because I wasn't sure where to do that). I guess we could have been just adding braces all along.


Thanks.
-boris
