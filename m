Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:63699 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755399Ab3GYMgd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jul 2013 08:36:33 -0400
Date: Thu, 25 Jul 2013 08:35:42 -0400
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: "J.Bruce Fields" <bfields@citi.umich.edu>, Ben Myers <bpm@sgi.com>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD/sunrpc: avoid deadlock on TCP connection due to
 memory pressure.
Message-ID: <20130725123542.GA19556@umich.edu>
References: <20130710022735.GI8281@fieldses.org>
 <20130710143233.77e35721@notabene.brown>
 <20130710190727.GA22305@fieldses.org>
 <20130715143203.51bc583b@notabene.brown>
 <20130716015803.GA5271@fieldses.org>
 <20130716140021.312b5b07@notabene.brown>
 <20130716142430.GA11977@fieldses.org>
 <20130718000319.GL1681@sgi.com>
 <20130724210746.GB5777@fieldses.org>
 <20130725113023.7bcbc347@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130725113023.7bcbc347@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good work! Thanks for fixing this.
