Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:60966 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965126Ab2EOP2E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 11:28:04 -0400
Date: Tue, 15 May 2012 11:27:35 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] NFS: kmalloc() doesn't return an ERR_PTR()
Message-ID: <20120515152735.GA11230@umich.edu>
References: <20120514194528.GA19613@elgon.mountain>
 <4FB25EA7.9050702@panasas.com>
 <20120515135733.GJ16984@mwanda>
 <4FB2659C.5090005@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FB2659C.5090005@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:

  > Normally we wouldn't put an unlikely() here.  It makes the code
  > less readable and it's not going to affect benchmarks.  But I can
  > add one if people prefer.
  > 

  Personally It makes it more readable for me. It's like a statement:
  "error, always slow-path case here". I have brain parsers set
  for these.

Personally I don't like it.  It's a hint for the compiler.  Remember when
code was liberally sprinkled with "register" modifiers on local variables?
Turned out the compiler was smarter than we were, and those modifiers were
hurting performance.  I'd rather let the compiler decide how to optimize.
