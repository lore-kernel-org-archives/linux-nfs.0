Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46073 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716Ab0IHRUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Sep 2010 13:20:43 -0400
Date: Wed, 8 Sep 2010 13:19:54 -0400
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: is 'umount' asynchronous?
Message-ID: <20100908171954.GA31634@fieldses.org>
References: <4C86D4E1.4000403@candelatech.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C86D4E1.4000403@candelatech.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 07, 2010 at 05:12:17PM -0700, Ben Greear wrote:
> While testing NFSv4 over TCPv6 on 2.6.36-rc3 + my srcaddr= patch today,
> I noticed that I was getting 'busy' errors from umount if I closed a
> file in a program and then had it immediately system("umount ...");
> 
> If I retry the umount a few times, it will start returning 'already unmounted'.
> It took around 50-100ms (I was sleeping 50ms between umount attempts).
> 
> Is that expected behaviour?  Seems we never needed any retries and never
> got 'busy' on 2.6.34 and earlier.

I've had this:

	# ARGH: getting a spurious EBUSY on some
	# umounts; this helps:
	sleep 1;

in my test scripts for a while, and haven't tried to investigate why
it's happening.  (Checking git logs: I added that in July 2008.)

--b.
