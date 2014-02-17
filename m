Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm21.bullet.mail.bf1.yahoo.com ([98.139.212.180]:38768 "EHLO
	nm21.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754322AbaBQUTO convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Feb 2014 15:19:14 -0500
References: <1392466251.41282.YahooMailNeo@web140003.mail.bf1.yahoo.com>	 <1392494917.71728.YahooMailNeo@web140002.mail.bf1.yahoo.com>	 <20140215203015.GA4528@pd.tnic>	 <1392498262.98385.YahooMailNeo@web140003.mail.bf1.yahoo.com>	 <20140215232508.GB4508@pd.tnic> <1392571653.44773.4.camel@leira.trondhjem.org>
Message-ID: <1392667974.22806.YahooMailNeo@web140003.mail.bf1.yahoo.com>
Date: Mon, 17 Feb 2014 12:12:54 -0800 (PST)
From: John <da_audiophile@yahoo.com>
Reply-To: John <da_audiophile@yahoo.com>
Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Borislav Petkov <bp@alien8.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: lkml <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "mlindner@marvell.com" <mlindner@marvell.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <1392571653.44773.4.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>





----- Original Message -----
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> To: Borislav Petkov <bp@alien8.de>; Linux NFS Mailing List <linux-nfs@vger.kernel.org>
> Cc: John <da_audiophile@yahoo.com>; lkml <linux-kernel@vger.kernel.org>; "netdev@vger.kernel.org" <netdev@vger.kernel.org>; "stephen@networkplumber.org" <stephen@networkplumber.org>; "mlindner@marvell.com" <mlindner@marvell.com>; J. Bruce Fields <bfields@fieldses.org>
> Sent: Sunday, February 16, 2014 12:27 PM
> Subject: Re: [BUG] unable to handle kernel NULL pointer dereference
> 
> Please ensure that you post to the linux-nfs@vger.kernel.org when
> reporting NFS and RPC related bugs.
>  
> Does the following patch help?
> 


Trond.  Yes, your patch fixes the regression for me; tested on v3.13.3,  I do not know the process by which patches get into the next stable release (minor version).  My hope is that once peer-reviewed, this patch gets into the 3.13.4 and since the 3.12 series is not EOL yet, into 3.12.12 as well.  Thank you for the time and effort!
