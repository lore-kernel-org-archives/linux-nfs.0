Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:51900 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbcFJBdh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 21:33:37 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <18266C54-EE2D-4E79-9216-77D1B17A1B85@linuxhacker.ru>
Date: Thu, 9 Jun 2016 21:33:24 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <0413AB81-9BA5-41CF-B736-3F7B8909897B@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <20160603033750.GL14480@ZenIV.linux.org.uk> <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru> <20160603042648.GN14480@ZenIV.linux.org.uk> <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru> <20160603055655.GQ14480@ZenIV.linux.org.uk> <18266C54-EE2D-4E79-9216-77D1B17A1B85@linuxhacker.ru>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 6, 2016, at 7:36 PM, Oleg Drokin wrote:

> Well, I have some bad news.
> 
> This patch does not fix the issue 100% of the time apparently, I just hit it again.

Ok, so now finally a piece of good news.
Whatever was causing this other much harder to hit crash is gone in -rc2, gone are
some other disturbing things I saw.

Hopefully this patch will get propagated everywhere soonish.