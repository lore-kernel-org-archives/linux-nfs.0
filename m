From: Neil Brown <neilb@suse.de>
Subject: RE: nfs new_cache mechanism and older kernel
Date: Fri, 8 Feb 2008 12:39:05 +1100
Message-ID: <18347.45753.421577.328747@notabene.brown>
References: <DDFD17CC94A9BD49A82147DDF7D545C5798775@exchange.ZeugmaSystems.local>
	<18347.42555.441287.802490@notabene.brown>
	<DDFD17CC94A9BD49A82147DDF7D545C57987CF@exchange.ZeugmaSystems.local>
	<18347.44054.920429.277506@notabene.brown>
	<DDFD17CC94A9BD49A82147DDF7D545C5798802@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-nfs@vger.kernel.org>
To: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52959 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932462AbYBHBjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 20:39:06 -0500
In-Reply-To: message from Anirban Sinha on Thursday February 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday February 7, ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org wrote:
> Perfect! That was indeed the problem. Thank you so much. Btw, so when
> mountd starts, it checks whether or not the new cache mechanism is being
> used and acts accordingly, right? (I am being lazy by not going through
> the codebase to find that out myself).

Correct on both counts :-)

NeilBrown
