Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-in-01.arcor-online.net ([151.189.21.41]:40978 "EHLO
	mail-in-01.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753955Ab3EKJ4j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 May 2013 05:56:39 -0400
Date: Sat, 11 May 2013 11:56:35 +0200
From: Andreas Radke <a.radke@arcor.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 ACL issues since 3.0.72 leading to corrupt files (xfs)
Message-ID: <20130511115635.75a48294@workstation64.home>
In-Reply-To: <1368240992.2998.6.camel@leira.trondhjem.org>
References: <20130510215553.0a1130be@laptop64.home>
	<1368240992.2998.6.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Sat, 11 May 2013 02:56:33 +0000
schrieb "Myklebust, Trond" <Trond.Myklebust@netapp.com>:

> On Fri, 2013-05-10 at 21:55 +0200, Andreas Radke wrote:
> > I'm running a server with a NFSv4 share drive that also hosts a Mail
> > directory I provide with dovecot IMAP server. Dovecot has ACL plugin
> > disabled.
> > 
> > Since the 4 NFSv4 ACL related commits in kernel 3.0.72 (and all
> > other stable kernels) all kernels until the recent stable releases
> > give such errors when changing :
> 
> Which 4 NFSv4 acl related commits?

It should be one of these commits:

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=7e36f505caf7882b6cc89ecedcd7f26749ef917a
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=2c34b4ae8f8228e1ec083be0333426eca4a31357
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=01b140abad66f022ff6dff7cc1307b07281035fa
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=c938c22b48302eeb9a6f3cc83f223f37d98ba6f7
 
> Have you bisected in order to figure out which one is the culprit? If
> not, how do you know that this is related to NFSv4 acl changes?

The problem had started with kernel 3.0.72 and all other stable kernels
that included these commits (my distro only ships 3.0.x and 3.8.x tree
at that time). All other commits from 3.0.71 to 3.0.72 look unrelated to
my server setup. Local clients can run up to date kernels without any problems.
Other people have reported also issues with ACL on servers since that
update.

I can reproduce the issue instantly when marking lots of mails as
read/unread that leads instantly to corrupt files on the server drive.

Because it hosts serious data I can't play too much with that machine.
It would be nice if you could point me the the related commit. It will
cost me lots of time to build a kernel with the patches reverted one by
one and I'm afraid of loosing more data.

-Andy
