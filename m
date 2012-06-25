Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:6355 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab2FYCpw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Jun 2012 22:45:52 -0400
Date: Sun, 24 Jun 2012 19:45:52 -0700
From: Andi Kleen <ak@linux.intel.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120625024552.GJ4152@tassilo.jf.intel.com>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
 <1340587274.8758.11.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1340587274.8758.11.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I believe that the spinlock is there in order to ensure that the
> test_bit() and get_rpccred() are atomic w.r.t. garbage collection.

Normally RCU should ensure that already with minor care.
Only drop after a quiescent period and when the reference is still 0.
And drop always when the refcount goes to 0.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only
