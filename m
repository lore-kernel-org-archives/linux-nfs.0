Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39380 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934965Ab3DITI5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 15:08:57 -0400
Date: Tue, 9 Apr 2013 15:08:55 -0400
To: Bram Vandoren <brambi@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client hangs after server reboot
Message-ID: <20130409190855.GB3800@fieldses.org>
References: <CACQjR_AH-AZDVLGKK8ZOVmkvQ-MEPuNn_y-Tu-ibrb6Rf7aC+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CACQjR_AH-AZDVLGKK8ZOVmkvQ-MEPuNn_y-Tu-ibrb6Rf7aC+Q@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 09, 2013 at 05:51:40PM +0200, Bram Vandoren wrote:
> Hello,
> we have a FreeBSD 9.1 fileserver and several clients running kernel
> 3.8.4-102.fc17.x86_64. Everything works fine till we reboot the
> server. A fraction (1/10) of the clients don't resume the NFS session
> correctly. The server sends a NFS4ERR_STALE_STATEID. The client sends
> a RENEW to the server but no SETCLIENTID. (this should be the correct
> action from my very quick look at RFC 3530). After that the client
> continues with a few READ call and the process starts again with the
> NFS4ERR_STALE_STATEID response from the server. It generates a lot of
> useless network traffic.

   0.003754  a.b.c.2 -> a.b.c.120 NFS 122 V4 Reply (Call In 49) READ Status: NFS4ERR_STALE_STATEID
   0.003769  a.b.c.2 -> a.b.c.120 NFS 114 V4 Reply (Call In 71) RENEW

I don't normally use tshark, so I don't know--does the lack of a status
on that second line indicate that the RENEW succeeded?

Assuming the RENEW is for the same clientid that the read stateid's are
associated with--that's definitely a server bug.  The RENEW should be
returning STALE_CLIENTID.

--b.
