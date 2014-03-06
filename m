Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56877 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbaCFMfu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 07:35:50 -0500
Date: Thu, 6 Mar 2014 07:34:38 -0500
From: Jim Rees <rees@umich.edu>
To: Andrew Martin <amartin@xes-inc.com>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306123438.GA21799@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
 <20140306145042.6db53f60@notabene.brown>
 <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Given this is apache, I think if I were doing this I'd use ro,soft,intr,tcp
and not try to write anything to nfs.
