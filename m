Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw02.dd24.net ([193.46.215.43]:36737 "EHLO
	mailgw02.dd24.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab3JXQKZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 12:10:25 -0400
Received: from localhost (amavis01.dd24.net [192.168.1.111])
	by mailgw02.dd24.net (Postfix) with ESMTP id F3181356BF4
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 16:10:23 +0000 (GMT)
Received: from mailgw02.dd24.net ([192.168.1.197])
	by localhost (amavis01.dd24.net [192.168.1.105]) (amavisd-new, port 10197)
	with ESMTP id OHASqkugndT5 for <linux-nfs@vger.kernel.org>;
	Thu, 24 Oct 2013 16:10:17 +0000 (GMT)
Received: from [192.168.0.102] (ppp-88-217-86-191.dynamic.mnet-online.de [88.217.86.191])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailgw02.dd24.net (Postfix) with ESMTPSA id 79EF2356BEE
	for <linux-nfs@vger.kernel.org>; Thu, 24 Oct 2013 16:10:17 +0000 (GMT)
Message-ID: <1382631016.6907.64.camel@heisenberg.scientia.net>
Subject: Re: XATTRs in NFS?
From: Christoph Anton Mitterer <calestyo@scientia.net>
To: linux-nfs@vger.kernel.org
Date: Thu, 24 Oct 2013 18:10:16 +0200
In-Reply-To: <20131024112319.7ad9fd27@tlielax.poochiereds.net>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	 <1382624000.6907.8.camel@heisenberg.scientia.net>
	 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
	 <1382627225.899.76.camel@willson.li.ssimo.org>
	 <1382627496.6430.2.camel@leira.trondhjem.org>
	 <1382627770.899.79.camel@willson.li.ssimo.org>
	 <20131024112319.7ad9fd27@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 11:23 -0400, Jeff Layton wrote:
> I think the real solution if people need this is to lead an effort to
I'm often reading this argument,... "if people need this", respectively
the argument "XATTRs/ACLs" aren't widely used so we're not going to
support them.

IMHO that's no really an argument.... the simple reason that this isn't
widely used, is likely that there are still many places that don't
support it.

All the major Linux (disk) filesystems support it, right? ext*/btrfs/XFS
But many (even standard clients) do either not (e.g. normal GNU tar
format) or behave in a way that somehow break or lose XATTRs/ACLs (e.g.
vim),... NFS is another example - a very important IMHO since it is THE
network filesystem.

So sure,... not many people are using XATTRs, ACLs, but the reason is
simply, that there are still many obstacles in the way - in many cases
upstream refusing to solve these, for the reason that allegedly noone
uses XATTRs/ACLs.
(Which is btw. not fully true,... many modernish stuff like uses e.g.
ACLs like in /dev/).



I do agree that especially the ACLs from POSIX are not the best thing
(NFS4 ACLs are much better),... but I don't see the big problem with
key/value pairs from XATTRs.


Cheers,
Chris.

