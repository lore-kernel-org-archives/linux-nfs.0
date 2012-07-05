Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:27896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab2GEQ3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 12:29:04 -0400
Date: Thu, 5 Jul 2012 09:29:03 -0700
From: Andi Kleen <ak@linux.intel.com>
To: Fengguang Wu <fengguang.wu@intel.com>,
        Linux-NFS <linux-nfs@vger.kernel.org>, Trond.Myklebust@netapp.com
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120705162903.GF32640@tassilo.jf.intel.com>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
 <20120625024211.GA11057@localhost>
 <20120627180353.GO4152@tassilo.jf.intel.com>
 <20120705131105.GA13775@localhost>
 <20120705150509.GA12981@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120705150509.GA12981@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I know very little about this code, so take this with grain of salt!
> The cred symbol is set above but there is no guaranty that you will use
> it.  If you don't win, you should set it to NULL.

Yes you're probably right. Thanks.

-Andi

