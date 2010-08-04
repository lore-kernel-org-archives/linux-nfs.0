Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:52058 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666Ab0HDPpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 11:45:34 -0400
Date: Wed, 4 Aug 2010 11:45:33 -0400
From: Jim Rees <rees@umich.edu>
To: Andy Adamson <andros@netapp.com>
Cc: Jonathan Manton <jmanton@illinois.edu>, linux-nfs@vger.kernel.org
Subject: Re: Kerberized NFS (v3 and v4) does not work if Kerberos token is
 >= 2048 bytes (if PAGE_SIZE == 4096)
Message-ID: <20100804154533.GA13950@merit.edu>
References: <E820D075-2582-4FF8-B788-14D41070DA29@illinois.edu>
 <D17BAFDB-6B3B-40B6-9C28-5689D18FBBA5@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D17BAFDB-6B3B-40B6-9C28-5689D18FBBA5@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Andy Adamson wrote:

  > When a user with a Kerberos token of 2048 bytes or larger attempts to
  > access a filesystem mounted using Kerberized NFS, the NFS server locks up
  > for 30 seconds, and ultimately the call fails.

  Yes, this limitation has been known for a long time. We ran into this same
  issue using X.509 certs and spkm3. I imagine PKINIT will also hit this
  limitation.

But shouldn't it fail right away instead of locking up for 30 seconds?

Does the entire server lock up, or just that one rpc?

Can a malicious client use this as a DOS?  Does it require a valid ticket,
or will any ticket >= 2048 do?
