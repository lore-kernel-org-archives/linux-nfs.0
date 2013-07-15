Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:61845 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755428Ab3GONmT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 09:42:19 -0400
Date: Mon, 15 Jul 2013 09:42:11 -0400
From: Jim Rees <rees@umich.edu>
To: "J.Bruce Fields" <bfields@citi.umich.edu>
Cc: NeilBrown <neilb@suse.de>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130715134211.GA14237@umich.edu>
References: <20130710092255.0240a36d@notabene.brown>
 <20130710022735.GI8281@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130710022735.GI8281@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's the thread on netdev where we discussed this issue:
http://marc.info/?l=linux-netdev&m=121545498313619&w=2

Here is where I asked about an api to set a socket buf minimum:
http://marc.info/?l=linux-netdev&m=121554794432038&w=2

There are many subtleties, and I suggest anyone who wants to try to fix this
code should read the email thread. The netdev people were pretty insistent
that we turn on autotuning; David Miller said the old behavior was
equivalent to "turn[ing] off half of the TCP stack."
