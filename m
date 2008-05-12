From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix /proc/net/rpc/auth.unix.ip/content output [Was Re:
	stuff]
Date: Sun, 11 May 2008 20:40:26 -0400
Message-ID: <20080512004026.GA26939@fieldses.org>
References: <20080509192319.GG1907@fieldses.org> <20080509204807.GI1907@fieldses.org> <18471.35859.781495.449872@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Aurelien Charbon <aurelien.charbon@bull.net>,
	Brian Haley <brian.haley@hp.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33368 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496AbYELAk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2008 20:40:29 -0400
In-Reply-To: <18471.35859.781495.449872-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2008 at 10:15:15AM +1000, Neil Brown wrote:
> But I don't think the patch would apply to 2.6.25.  'git name-rev' on
> the offending commit say:
> 
> f15364bd4cf8799a7677b6daeed7b67d9139d974 tags/v2.6.26-rc1~1083^2~47
> 
> which means it was in 2.6.26-rc1 but not the previous release.

Ah!  You're right--I lose track of time too easily.

--b.
