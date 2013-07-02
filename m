Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54341 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab3GBPwn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 11:52:43 -0400
Date: Tue, 2 Jul 2013 11:52:41 -0400
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: exporting one directory sec=krb5 and another sec=sys?
Message-ID: <20130702155241.GE31697@fieldses.org>
References: <kqenqq$4f7$1@ultimate100.geggus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <kqenqq$4f7$1@ultimate100.geggus.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 26, 2013 at 12:46:18PM +0000, Sven Geggus wrote:
> Hello,
> 
> I'm trying to do the following in /etc/exports:
> 
> /storage/home *(rw,sec=krb5:krb5i:krb5p,no_subtree_check)
> /storage/data4hostx hostx(rw,sec=sys,no_subtree_check)
> 
> This does however not seem to work, I always seem to get "mount.nfs4:
> Operation not permitted".
> 
> If I remove either line everything works fine
> (of course in the spezified case only)
> 
> What am I doing wrong here?

If those two directories are on the same filesystem (not recommended),
you probably need to turn on subtree_check to get that to work.

--b.
