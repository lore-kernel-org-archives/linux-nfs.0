Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:46398 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110Ab0K2W0P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 17:26:15 -0500
Date: Mon, 29 Nov 2010 17:26:13 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Garzik <jeff@garzik.org>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>,
        sfaibish <sfaibish@emc.com>
Subject: Re: Block layout rpm
Message-ID: <20101129222613.GA1210@merit.edu>
References: <20101129210708.GA21682@merit.edu>
 <4CF4249F.9070400@garzik.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CF4249F.9070400@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jeff Garzik wrote:

  "pNFS will work with 32-bit linux and lesser hardware, but the you
  will not obtain the performance benefits of pNFS."
  
  That's just silly, and, I might even go so far as to say "wrong".
  The benefits of direct-to-storage access, without an MDS middle-man,
  are quite noticable even for 32-bit, underpowered, and/or embedded
  clients.

Agreed.  It used to say 64-bit only, and I added the part about 32-bit
because it does run on 32-bit, but really that should just come out.  I'll
fix it.
