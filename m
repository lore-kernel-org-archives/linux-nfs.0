Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:50610 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811AbaCEVL3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 16:11:29 -0500
Date: Wed, 5 Mar 2014 16:11:24 -0500
From: Jim Rees <rees@umich.edu>
To: Andrew Martin <amartin@xes-inc.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140305211124.GA16979@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
 <20140305201149.GA16212@umich.edu>
 <1106484945.149062.1394052088011.JavaMail.zimbra@xes-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1106484945.149062.1394052088011.JavaMail.zimbra@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Martin wrote:

  Isn't intr/nointr deprecated (since kernel 2.6.25)?

It isn't so much that it's deprecated as that it's now the default (except
that only SIGKILL will work).
