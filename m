Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53465 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759868Ab1CDRtx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 12:49:53 -0500
Date: Fri, 4 Mar 2011 12:49:52 -0500
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: hung iozone client bug recap
Message-ID: <20110304174952.GA19684@merit.edu>
References: <20110303222219.GA16426@merit.edu>
 <4D711318.7070909@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D711318.7070909@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  We are seeing this too with a straight Fedora 14 kernel.
      https://bugzilla.redhat.com/show_bug.cgi?id=669204
   
  Unfortunately we are not able to reproduce it as easily as 
  you are...

There's some really good info in those bug reports.  Thanks.

I tried really hard to reproduce this in Santa Clara but had no luck.  My
guess was that it was timing related, and since I was using VMs for the
clients the timing was not right to trigger this.
