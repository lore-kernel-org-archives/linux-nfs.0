Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53336 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216Ab1GIQEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 9 Jul 2011 12:04:31 -0400
Date: Sat, 9 Jul 2011 12:04:30 -0400
To: =?utf-8?Q?R=C3=BCdiger?= Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: kernel BUG at linux-2.6.37/fs/nfsd/nfs4state.c:391
Message-ID: <20110709160430.GA18444@fieldses.org>
References: <201107091244.08597.sweet_f_a@gmx.de>
 <201107091342.12448.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <201107091342.12448.sweet_f_a@gmx.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 09, 2011 at 01:42:10PM +0200, Rüdiger Meier wrote:
> Hi,
> 
> On Saturday 09 July 2011, Rüdiger Meier wrote:
> > Today I've got the following trace on opensuse 11.4 nfs server.
> 
> This seems to be opensuse related. I've posted more detailed here: 
> https://bugzilla.novell.com/show_bug.cgi?id=704788

This looks like the bug fixed by
23fcf2ec93fb8573a653408316af599939ff9a8e "nfsd4: fix oops on lock
failure".

--b.
