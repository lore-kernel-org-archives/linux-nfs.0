From: <Artem.Bityutskiy@nokia.com>
Subject: RE: hang in writeback code on nfsv4 mount
Date: Wed, 25 Aug 2010 06:09:41 +0200
Message-ID: <10B234E0D3A1CA469E00963BF106CA392D0DB7834C@NOK-EUMSG-02.mgdnok.nokia.com>
References: <20100825023425.GA24591@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
	<trond@netapp.com>, <hch@lst.de>, <jaxboe@fusionio.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:32152 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab0HYEMF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 00:12:05 -0400
In-Reply-To: <20100825023425.GA24591@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> As of 253c34e9b10c30d3064be654b5b78fbc1a8b1896 "writeback: prevent
> unnecessary bdi threads wakeups", any nfs mount hangs for me.  Is this a
> known issue?

I'll try to reproduce this and take a look. No, I did not see this. Is the commit you point
the result of git bisect ?

Artem.