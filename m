Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:53461 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbaCFQaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 11:30:20 -0500
Date: Thu, 6 Mar 2014 11:22:08 -0500
From: Jim Rees <rees@umich.edu>
To: Andrew Martin <amartin@xes-inc.com>
Cc: bhawley@luminex.com, NeilBrown <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306162208.GA18207@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
 <20140306145042.6db53f60@notabene.brown>
 <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
 <20140306163721.0edfb498@notabene.brown>
 <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry>
 <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Martin wrote:

  > From: "Jim Rees" <rees@umich.edu>
  > Given this is apache, I think if I were doing this I'd use ro,soft,intr,tcp
  > and not try to write anything to nfs.
  I was using tcp,bg,soft,intr when this problem occurred. I do not know if
  apache was attempting to do a write or a read, but it seems that tcp,soft,intr
  was not sufficient to prevent the problem. 

I had the impression from your original message that you were not using
"soft" and were asking if it's safe to use it. Are you saying that even with
the "soft" option the apache gets stuck forever?
