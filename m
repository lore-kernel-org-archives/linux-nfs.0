Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50159 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406Ab1CIUfX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 15:35:23 -0500
Date: Thu, 10 Mar 2011 07:35:15 +1100
From: NeilBrown <neilb@suse.de>
To: "Assarsson, Emil" <Emil.Assarsson@sonyericsson.com>
Cc: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: Re: mountd --manage-gids supports max 100 groups?
Message-ID: <20110310073515.799d1530@notabene.brown>
In-Reply-To: <2BF070A7A2375D46BA1B6087F8D5DCB678B8E772B8@seldmbx01.corpusers.net>
References: <2BF070A7A2375D46BA1B6087F8D5DCB678B8E772B8@seldmbx01.corpusers.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 9 Mar 2011 16:20:42 +0100 "Assarsson, Emil"
<Emil.Assarsson@sonyericsson.com> wrote:

> Hi All,
> 
> Running linux kernel 2.6.32 and nfs-utils 1.2.0 (Ubuntu Lucid)
> 
> A regular user in our company usually is member of more than 300 groups. Some user even have up to 600. We want to use the --manage-gids option for mountd. However it seems to me that it is limited to about 100 groups.
> 
> The reason seems to be that there is a hard limit for mountd but also that the /proc/net/rpc/auth.unix.gid/channel won't accept more than 1008 characters as input.
> 
> I tried to adjust the code for mountd so that it tried to add up to 1000 groups but then I ran in to the channel problem.
> 
> Can someone please guide me to the place where I can adjust this limit?
> 

The limit should be 8192, not 1008.

This is set in net/sunrpc/cache.c
If the write is less than one page, it is handled in cache_downcall().
If it is bigger it is passed to cache_slow_downcall() which stops at
8192 (but could trivially be make to handle more).

What is your evidence that '.../channel won't accept more than 1008
characters as input" ???

Thanks,
NeilBrown
