Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:53755 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457AbaCFDsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 22:48:07 -0500
Date: Wed, 5 Mar 2014 22:47:27 -0500
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Andrew Martin <amartin@xes-inc.com>, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306034727.GA18942@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
 <260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
 <20140305201149.GA16212@umich.edu>
 <1106484945.149062.1394052088011.JavaMail.zimbra@xes-inc.com>
 <20140305211124.GA16979@umich.edu>
 <20140306143454.75eb2726@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140306143454.75eb2726@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:

  On Wed, 5 Mar 2014 16:11:24 -0500 Jim Rees <rees@umich.edu> wrote:
  
  > Andrew Martin wrote:
  > 
  >   Isn't intr/nointr deprecated (since kernel 2.6.25)?
  > 
  > It isn't so much that it's deprecated as that it's now the default (except
  > that only SIGKILL will work).
  
  Not quite correct.  Any signal will work providing its behaviour is to kill
  the process.  So SIGKILL will always work, and SIGTERM SIGINT SIGQUIT etc
  will work providing that aren't caught or ignored by the process.

If that's true, then the man page is wrong and someone should fix it. I'll
work up a patch if someone can confirm the behavior.
