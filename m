Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:34035 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759721Ab2BJS21 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 13:28:27 -0500
Message-ID: <4F35603A.5050508@fifthhorseman.net>
Date: Fri, 10 Feb 2012 13:21:46 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: steve <steve@steve-ss.com>
CC: whats_up@gmx.net, linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
References: <20120210154526.7b504146@little-poseidon> <4F35512A.9050500@steve-ss.com> <20120210184154.03fb6907@little-poseidon> <4F355CD2.6040603@steve-ss.com>
In-Reply-To: <4F355CD2.6040603@steve-ss.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/10/2012 01:07 PM, steve wrote:
> Officially, you should not export from a pseudo root. Please see the
> last few lines in the link I sent.

That link offers the same assertion but no explanation for it.  Can you
explain why that's the recommendation?

If an admin were to remove fsid=0 from their exports line, they'd also
need to adjust the paths in all the connecting clients, right?

	--dkg
