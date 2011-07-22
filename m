Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:40077 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab1GVOST (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 10:18:19 -0400
Subject: Re: [PATCH/RFC v2 0/13] enable SKB paged fragment lifetime
 visibility
From: Ian Campbell <Ian.Campbell@eu.citrix.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20110722.071349.1486529438674839197.davem@davemloft.net>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <20110722.071349.1486529438674839197.davem@davemloft.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jul 2011 15:18:16 +0100
Message-ID: <1311344296.12772.80.camel@zakaz.uk.xensource.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-22 at 15:13 +0100, David Miller wrote:
> Well, Ian, because you put all of these "struct page *" MM layer
> const changes in here I can't just apply this series once you
> get it ready enough from a networking perspective.
> 
> Why not do the const crap later, so it can be done independently
> of these changes and not be a dependency upon them?

Initially it was to help me find locations which needed consideration
(since it caused build failures) but I can flip it round now, sure.

> I know you want to pass const page structs down as far as possible,
> but that can wait for later, make the networking bits work on
> non-const pointers for now.

Will do.

Ian.

