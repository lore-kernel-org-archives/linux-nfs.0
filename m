Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:65457 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881Ab3DMPIz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Apr 2013 11:08:55 -0400
Date: Sat, 13 Apr 2013 11:08:48 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names
Message-ID: <20130413150848.GA780@umich.edu>
References: <1365862193-21986-1-git-send-email-steved@redhat.com>
 <1365862193-21986-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1365862193-21986-2-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I find this very confusing. You've got a global named "avoid_dns", which you
turn off if you have the "-D" option. And if it's set, you do a dns lookup:

  +	if (avoid_dns) {
...
  +			do_dns_lookup = 1; /* IPv4 */

At the very least I would call it something like "do_ptr_lookup" and invert
its meaning.
