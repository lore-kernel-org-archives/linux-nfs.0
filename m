Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr13.xs4all.nl ([194.109.24.33]:1508 "EHLO
	smtp-vbr13.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757519Ab0IGTZG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 15:25:06 -0400
Subject: Re: [PATCH 02/03]: sunrpc: make auth_hashtable_size param mode 0444
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1283885932.2788.69.camel@heimdal.trondhjem.org>
References: <20100822182848.GA26590@xs4all.net>
	 <20100822183109.GB26607@xs4all.net>
	 <1283885932.2788.69.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 07 Sep 2010 21:24:09 +0200
Message-ID: <1283887449.12858.208.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-07 at 14:58 -0400, Trond Myklebust wrote:
> On Sun, 2010-08-22 at 20:31 +0200, Miquel van Smoorenburg wrote:
> > The auth_hashtable_size parameter shows up in
> > /sys/module/sunrpc/parameters with mode 0644. However the hashtables
> > are allocated when the module is loaded, and changing the parameter
> > afterwards doesn't do much. So make it read-only.
> 
> The above observation is only correct for AUTH_SYS. The reason for
> making the mode 0644 was to allow users to change the value after
> loading if they want to use RPCSEC_GSS.

Right, I can see that being useful. It's confusing though. It'd be more
clear if there was a seperate knob to tune just
rpcsec_auth_hashtable_size. Anyway, never mind then.

Mike.

