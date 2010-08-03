Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:48025
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752192Ab0HCVTQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 17:19:16 -0400
Date: Tue, 3 Aug 2010 23:19:06 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803211906.GA24236@gibson.comsick.at>
References: <20100803154556.GA6262@gibson.comsick.at>
 <20100803194342.GE31579@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803194342.GE31579@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Bruce.

I was a little bit early with my success report. I can now successfully
mount the exports with sec=krb5 and can also read and write from linux
clients. But now I get the following messages from the kernel on the
server itself. This apparently happens when I try to read/write to the
export.

Aug  3 23:12:23 gibson kernel: RPC: AUTH_GSS upcall timed out.
Aug  3 23:12:23 gibson kernel: Please check user daemon is running.

Of course all the daemons on the server are running and the system seems
to work fine otherwise.

Kind regards,
Michael
