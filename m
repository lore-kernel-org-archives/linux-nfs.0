From: <Artem.Bityutskiy@nokia.com>
Subject: RE: hang in writeback code on nfsv4 mount
Date: Fri, 27 Aug 2010 18:21:08 +0200
Message-ID: <10B234E0D3A1CA469E00963BF106CA392D0DB78355@NOK-EUMSG-02.mgdnok.nokia.com>
References: <20100825023425.GA24591@fieldses.org>
 <1282889595.2763.14.camel@localhost> <1282901780.12016.54.camel@localhost>
 <4C77B873.8010306@netapp.com>,<20100827160912.GA18790@fieldses.org>,<10B234E0D3A1CA469E00963BF106CA392D0DB78354@NOK-EUMSG-02.mgdnok.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <jaxboe@fusionio.com>, <linux-nfs@vger.kernel.org>,
	<trond@netapp.com>, <hch@lst.de>
To: <Artem.Bityutskiy@nokia.com>, <bfields@fieldses.org>,
	<bjschuma@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:48412 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898Ab0H0QXE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 12:23:04 -0400
In-Reply-To: <10B234E0D3A1CA469E00963BF106CA392D0DB78354-xJW1crHCIS+8kqYwC468Frtp2NbXvJi8gfoxzgwHRXE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I need to look more. But so far I do not really understand what could make kthread_stop() wait
> forever. I looked into the code, and thought may be barriers are missing there, but I is unlikely
> this generic type of code would have bugs.

> I cannot see what happens from the code and need to experiment with printks and other debugging
> things. Will do as soon as I have a possibility.

Oh, and pardon for top posting, writing from web interface to outlook. Forgot to strip the mail.

Artem.