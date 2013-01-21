Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.eu.citrix.com ([46.33.159.39]:25091 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3AUPbK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 10:31:10 -0500
Message-ID: <1358781685.3279.222.camel@zakaz.uk.xensource.com>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
From: Ian Campbell <Ian.Campbell@citrix.com>
To: Alex Bligh <alex@alex.org.uk>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 21 Jan 2013 15:21:25 +0000
In-Reply-To: <4B8CA29C9B365854E56ACBE6@Ximines.local>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>
	 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
	 <4B8CA29C9B365854E56ACBE6@Ximines.local>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-01-21 at 15:10 +0000, Alex Bligh wrote:
> >> I thought that Ian was working on a fix for this issue. At one point, he
> >> had a bunch of patches to allow sendpage() to call you back when the
> >> transmission was done. What happened to those patches?
> >
> > No idea (I don't work with Ian but have taken the liberty of copy him).

I'm afraid I've rather dropped the ball on these patches due to lack of
time.

Ian.

