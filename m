Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54962 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758725Ab2INMET (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 08:04:19 -0400
Date: Fri, 14 Sep 2012 08:04:10 -0400
From: Jim Rees <rees@umich.edu>
To: Richard Allen <rallen@plus.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Debian and Netapp NFSv4 locks/owner exhaustion
Message-ID: <20120914120410.GA29160@umich.edu>
References: <5052EAEB.7060309@plus.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5052EAEB.7060309@plus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Richard Allen wrote:

  The main question I have is whether the bugs Netapp mentioned in the
  Redhat kernel have been fixed in the backported Debian kernel we are
  running, and if so, what version the fixes have been introduced in
  (and if not, what version the fixes *will* be introduced in)?

The way I would do this is to install the source package for the kernel
you're running, then look to see if the patch has been applied to it.  If
not you could try applying it yourself.
