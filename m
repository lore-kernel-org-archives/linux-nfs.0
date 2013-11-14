Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:54661 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150Ab3KNDM7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 22:12:59 -0500
Date: Wed, 13 Nov 2013 22:12:53 -0500
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Charles Edward Lever <chuck.lever@oracle.com>
Subject: Re: please proof-read: updates to nfs.man for some missing options.
Message-ID: <20131114031253.GA9522@umich.edu>
References: <20131114140244.6f7c0094@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131114140244.6f7c0094@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:

  +.BR addr= ip-address
  +This option is rarely used but can provide an explicit IP address of
  +the NFS server in cases where the server is multi-homed.
  +.TP 1.5i

I would change "rarely used" to "usually not needed." Also I think you have
this option in here twice.
