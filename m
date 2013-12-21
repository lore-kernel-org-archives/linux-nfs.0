Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:35349 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3LUIRO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Dec 2013 03:17:14 -0500
Date: Sat, 21 Dec 2013 09:17:07 +0100
From: Alexander Aring <alex.aring@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, werner@almesberger.net
Subject: Re: [PATCH] nfs: fix dead code of ipv6_addr_scope
Message-ID: <20131221081706.GA11689@omega>
References: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I saw right now file "./net/sctp/ipv6.c" in function sctp_v6_scope has
the same issue.

- Alex
