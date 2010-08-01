Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52103 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab0HATlx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Aug 2010 15:41:53 -0400
Subject: Re: auth_gss.c - rcu dereference warning
From: Johannes Berg <johannes@sipsolutions.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <1280604011.3125.28.camel@heimdal.trondhjem.org>
References: <1280227718.3755.3.camel@jlt3.sipsolutions.net>
	 <1280604011.3125.28.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 01 Aug 2010 21:41:49 +0200
Message-ID: <1280691709.3725.4.camel@jlt3.sipsolutions.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-07-31 at 15:20 -0400, Trond Myklebust wrote:
> On Tue, 2010-07-27 at 12:48 +0200, Johannes Berg wrote:

> Does the following patch help?

Yes, thanks.

Tested-by: Johannes Berg <johannes@sipsolutions.net>
    
> There is no need to delete the gss context separately from the rest
> of the security context information, and doing so gives rise to a
> an rcu_dereference_check() warning.

typo: "a an"

johannes


