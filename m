Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51781 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598Ab3ELD7v convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 May 2013 23:59:51 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Andreas Radke <a.radke@arcor.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 ACL issues since 3.0.72 leading to corrupt files (xfs)
Date: Sun, 12 May 2013 03:59:47 +0000
Message-ID: <1368331183.7978.6.camel@leira.trondhjem.org>
References: <20130510215553.0a1130be@laptop64.home>
	 <1368240992.2998.6.camel@leira.trondhjem.org>
	 <20130511115635.75a48294@workstation64.home>
In-Reply-To: <20130511115635.75a48294@workstation64.home>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2013-05-11 at 11:56 +0200, Andreas Radke wrote:
> Am Sat, 11 May 2013 02:56:33 +0000
> schrieb "Myklebust, Trond" <Trond.Myklebust@netapp.com>:
> 
> > On Fri, 2013-05-10 at 21:55 +0200, Andreas Radke wrote:
> > > I'm running a server with a NFSv4 share drive that also hosts a Mail
> > > directory I provide with dovecot IMAP server. Dovecot has ACL plugin
> > > disabled.
> > > 
> > > Since the 4 NFSv4 ACL related commits in kernel 3.0.72 (and all
> > > other stable kernels) all kernels until the recent stable releases
> > > give such errors when changing :
> > 
> > Which 4 NFSv4 acl related commits?
> 
> It should be one of these commits:
> 
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=7e36f505caf7882b6cc89ecedcd7f26749ef917a
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=2c34b4ae8f8228e1ec083be0333426eca4a31357
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=01b140abad66f022ff6dff7cc1307b07281035fa
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=c938c22b48302eeb9a6f3cc83f223f37d98ba6f7
>  
> > Have you bisected in order to figure out which one is the culprit? If
> > not, how do you know that this is related to NFSv4 acl changes?
> 
> The problem had started with kernel 3.0.72 and all other stable kernels
> that included these commits (my distro only ships 3.0.x and 3.8.x tree
> at that time). All other commits from 3.0.71 to 3.0.72 look unrelated to
> my server setup. Local clients can run up to date kernels without any problems.
> Other people have reported also issues with ACL on servers since that
> update.
> 
> I can reproduce the issue instantly when marking lots of mails as
> read/unread that leads instantly to corrupt files on the server drive.
> 
> Because it hosts serious data I can't play too much with that machine.
> It would be nice if you could point me the the related commit. It will
> cost me lots of time to build a kernel with the patches reverted one by
> one and I'm afraid of loosing more data.
> 
> -Andy

Only one of those is an NFS server change (the one which rejects
negative server lengths). Unless your NFS server is also acting as an
NFS client, it is highly unlikely that the other patches are relevant.

So the relevant commit to revert should be
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=7e36f505caf7882b6cc89ecedcd7f26749ef917a

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
