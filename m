Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail04-md.ns.itscom.net ([175.177.155.114]:40984 "EHLO
	mail04-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbbI1C1J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2015 22:27:09 -0400
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: v4.3-rc2, fault in sock_release via nfs_put_client
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <CAHQdGtRjsqdHGpdFJc7AGm=gFXBdKBSPyQpvUPWJZtmwx0FypA@mail.gmail.com>
References: <9143.1443358024@jrobl> <CAHQdGtRjsqdHGpdFJc7AGm=gFXBdKBSPyQpvUPWJZtmwx0FypA@mail.gmail.com>
Date: Mon, 28 Sep 2015 11:27:06 +0900
Message-ID: <17426.1443407226@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust:
> On Sun, Sep 27, 2015 at 8:47 AM, J. R. Okajima <hooanon05g@gmail.com> wrote:
> > I don't know whether this is a known issue or not (since I was off from
> > development for a few months), but I've got a "general protection fault:
> > 0000" message from linux-4.3-rc2.
	:::
> There is a fix for this issue in v4.3-rc3. Please see
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=79234c3db6842a3de03817211d891e0c2878f756

Thank you.
Confirmed the problem is gone.


J. R. Okajima
