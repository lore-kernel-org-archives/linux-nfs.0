Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:44304 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751112Ab1LHXki (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 18:40:38 -0500
From: =?utf-8?q?R=C3=BCdiger_Meier?= <sweet_f_a@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: [RFC][PATCH] libtirpc,rpcbind: move socket from /var/run to /run
Date: Fri, 9 Dec 2011 00:40:33 +0100
References: <1323371940-9140-1-git-send-email-teg@jklm.no>
In-Reply-To: <1323371940-9140-1-git-send-email-teg@jklm.no>
Cc: Tom Gundersen <teg@jklm.no>, Kay Sievers <kay.sievers@vrfy.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <201112090040.35286.sweet_f_a@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 08 December 2011, Tom Gundersen wrote:
> /run is guaranteed to be available and writeable at any time, whereas
> /var might be on a separate partition and hence not available during
> early boot. By moving the socket from /var to /run we are able to use
> rpcbind earlier, which would in particular make a difference in case
> /var is on an nfs mount, something I am currently seeing bug reports
> about.

I don't have /run on any system so IMHO it's not really guaranteed. Does 
it will be created if not existent? I hope not.

cu,
Rudi
