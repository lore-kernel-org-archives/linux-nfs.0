Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-in-13.arcor-online.net ([151.189.21.53]:48725 "EHLO
	mail-in-13.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753149Ab3ELKUG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 May 2013 06:20:06 -0400
Date: Sun, 12 May 2013 12:19:58 +0200
From: Andreas Radke <a.radke@arcor.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 ACL issues since 3.0.72 leading to corrupt files (xfs)
Message-ID: <20130512121958.1c1be5ec@workstation64.home>
In-Reply-To: <1368331183.7978.6.camel@leira.trondhjem.org>
References: <20130510215553.0a1130be@laptop64.home>
	<1368240992.2998.6.camel@leira.trondhjem.org>
	<20130511115635.75a48294@workstation64.home>
	<1368331183.7978.6.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Sun, 12 May 2013 03:59:47 +0000
schrieb "Myklebust, Trond" <Trond.Myklebust@netapp.com>:

> Only one of those is an NFS server change (the one which rejects
> negative server lengths). Unless your NFS server is also acting as an
> NFS client, it is highly unlikely that the other patches are relevant.
> 
> So the relevant commit to revert should be
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?h=linux-3.0.y&id=7e36f505caf7882b6cc89ecedcd7f26749ef917a
> 

Thanks for your help. Unfortunately even reverting all 4 commits didn't
solve my file corrupting issues. Now I need to check what other 
commit in 3.0.72 could cause this.

Sorry for noise here.

-Andy
