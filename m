Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:57008 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab2LGVaA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2012 16:30:00 -0500
Date: Fri, 7 Dec 2012 21:35:20 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: Christoph Hellwig <hch@infradead.org>, <linux-cifs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <wine-devel@winehq.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121207213520.05dd5a3b@pyramind.ukuu.org.uk>
In-Reply-To: <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
	<20121207161602.GA17710@infradead.org>
	<495d17310e0a687d446afc86def0f058@office.etersoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The problem is the possibility of denial-of-service attacks here. We 
> can try to prevent them by:
> 1) specifying an extra security bit on the file that indicates that 
> share flags are accepted (like we have for mandatory locks now) and 
> setting it for neccessary files only, or
> 2) adding a special mount option (but it it probably makes sense if we 
> decided to add this support for CIFS and NFS only).

3) making it a property that the process opts into - the same fs can have
Linux and wine users at once.

But for such a big set of changes and with the kind of potential fallout
you need to demonstrate a good practical use case IMHO, not just a "neat
idea I had".

Alan
