From: Jim Rees <rees@umich.edu>
Subject: Re: NFS and mobile clients - can it work?
Date: Wed, 24 Sep 2008 11:52:46 -0400
Message-ID: <20080924155246.GA24059@citi.umich.edu>
References: <18646.58594.377630.950531@notabene.brown> <48DA5B93.5030307@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:46412 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752117AbYIXPxA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2008 11:53:00 -0400
In-Reply-To: <48DA5B93.5030307-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:

  Could this possibly be handled by some type of user-level connection
  manager that would be able to deal with the changing of a server's IP
  address?

This shouldn't be necessary.  The nfs client already deals successfully with
the case where a tcp connection is closed unexpectedly.  All that's needed
is to make sure the connection closes when the client moves.  If the network
layer doesn't do this already, it should.
