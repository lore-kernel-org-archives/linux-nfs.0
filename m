Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:48308 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab1FPQ1I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 12:27:08 -0400
Date: Thu, 16 Jun 2011 12:27:07 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 2/2] remove -fwritable-strings for gcc 4.0
Message-ID: <20110616162707.GA25373@merit.edu>
References: <cover.1308241259.git.rees@umich.edu>
 <41c8992e9446c712542515a85a8b4abb83476a9d.1308241259.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <41c8992e9446c712542515a85a8b4abb83476a9d.1308241259.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim Rees wrote:

  Signed-off-by: Jim Rees <rees@umich.edu>
  ---
   tests.init |    7 +++++++
   1 files changed, 7 insertions(+), 0 deletions(-)
  
  diff --git a/tests.init b/tests.init
  index 69b51bf..5d93eb5 100644
  --- a/tests.init
  +++ b/tests.init
  @@ -210,6 +210,13 @@ LOCKTESTS=`echo tlocklfs tlock64`
   #UMOUNT=/bin/umount
   #LOCKTESTS=`echo tlocklfs tlock64`
   
  +# Use with Linux 2.6 / gcc 4.0
  +CFLAGS=`echo -DLINUX -DGLIBC=22 -DMMAP -DSTDARG`
  +LIBS=`echo -lnsl`
  +MOUNT=/bin/mount
  +UMOUNT=/bin/umount
  +LOCKTESTS=`echo tlocklfs tlock64`
  +
   # Use with Linux if your distro doesn't provide a "cc".
   #CC=gcc

I guess those lines should actually be commented out.
