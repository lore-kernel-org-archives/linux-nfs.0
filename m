Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0175.hostedemail.com ([216.40.44.175]:38736 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753207AbcCYSep (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2016 14:34:45 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by smtpgrave04.hostedemail.com (Postfix) with ESMTP id 551CCB11EA
	for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2016 18:25:22 +0000 (UTC)
Message-ID: <1458930317.29362.3.camel@perches.com>
Subject: Re: [PATCH] nfds: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL
 postfix
From: Joe Perches <joe@perches.com>
To: Christoph Hellwig <hch@lst.de>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Fri, 25 Mar 2016 11:25:17 -0700
In-Reply-To: <20160325180422.GA15549@lst.de>
References: <1458902831-24673-1-git-send-email-geert@linux-m68k.org>
	 <20160325180422.GA15549@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-03-25 at 19:04 +0100, Christoph Hellwig wrote:
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Outside of the known 64 bit only uses,
this shows a few oddities too:

$ git grep -P -w -i '0x[0-9a-f]{9,16}(?!ull|ll)'
