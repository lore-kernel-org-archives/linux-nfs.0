Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:52816 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817AbaCFStL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 13:49:11 -0500
Date: Thu, 6 Mar 2014 13:48:47 -0500
From: Jim Rees <rees@umich.edu>
To: Andrew Martin <amartin@xes-inc.com>
Cc: bhawley@luminex.com, NeilBrown <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306184847.GA18850@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <1853694865.210849.1394082223818.JavaMail.zimbra@xes-inc.com>
 <20140306163721.0edfb498@notabene.brown>
 <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry>
 <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com>
 <20140306162208.GA18207@umich.edu>
 <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com>
 <20140306173632.GA18545@umich.edu>
 <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Martin wrote:

  > From: "Jim Rees" <rees@umich.edu>
  > Why would a bunch of blocked apaches cause high load and reboot?
  What I believe happens is the apache child processes go to serve
  these requests and then block in uninterruptable sleep. Thus, there
  are fewer and fewer child processes to handle new incoming requests.
  Eventually, apache would normally kill said children (e.g after a 
  child handles a certain number of requests), but it cannot kill them
  because they are in uninterruptable sleep. As more and more incoming
  requests are queued (and fewer and fewer child processes are available
  to serve the requests), the load climbs.
  
But Neil says the sleeps should be interruptible, despite what the man page
says.

Trond, as far as you know, should a soft mount be interruptible by SIGINT,
or should it require a SIGKILL?
