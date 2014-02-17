Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.skyhub.de ([78.46.96.112]:57923 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbaBQUbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Feb 2014 15:31:00 -0500
Date: Mon, 17 Feb 2014 21:30:57 +0100
From: Borislav Petkov <bp@alien8.de>
To: John <da_audiophile@yahoo.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "mlindner@marvell.com" <mlindner@marvell.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
Message-ID: <20140217203057.GJ4559@pd.tnic>
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>
 <20140215203015.GA4528@pd.tnic>
 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>
 <20140215232508.GB4508@pd.tnic>
 <1392571653.44773.4.camel@leira.trondhjem.org>
 <1392667974.22806.YahooMailNeo@web140003.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1392667974.22806.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 17, 2014 at 12:12:54PM -0800, John wrote:
> Trond.  Yes, your patch fixes the regression for me; tested on
> v3.13.3,  I do not know the process by which patches get into
> the next stable release (minor version).  My hope is that once
> peer-reviewed, this patch gets into the 3.13.4 and since the 3.12
> series is not EOL yet, into 3.12.12 as well.  Thank you for the time
> and effort!

Basically you say

Tested-by: John <da_audiophile@yahoo.com>

Trond adds stable to CC, sends it to Linus and it trickles down to
3.12.x and 3.13.x stable.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
