Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-out2.uio.no ([129.240.10.58]:45731 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756260Ab2FYNq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jun 2012 09:46:57 -0400
Message-ID: <1340632000.9620.7.camel@lade.trondhjem.org>
Subject: Re: LAYOUTCOMMIT/LAYOUTRETURN
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Johannes Schild <JSchild@gmx.de>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Jun 2012 09:46:40 -0400
In-Reply-To: <20120625074306.48500@gmx.net>
References: <20120625074306.48500@gmx.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-06-25 at 09:43 +0200, Johannes Schild wrote:
> Hi Guys,
> 
> i have another question on pNFS. I looked at my Wireshark protocols, while i used the FILE-Layout, and i wondered why i have no LAYOUTCOMMIT/LAYOUTRETURN statements in my protocols.
> I transfered one file to my storage server (NETAPP Simulator 8.1 C-Mode) and i only got a LAYOUTGET.
> 
> cat /proc/self/mountstats | grep LAYOUT says:
> nfsv4: bm0=0xfafe8fff,bml=0x60fdfffe,acl=0x3,sessions,pnfs=LAYOUT_NFSV4_1_FILES
>     LAYOUTGET: 1 1 0 216 236 0 1 1
>  LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
>  LAYOUTRETURN: 0 0 0 0 0 0 0 0 

A pNFS client should never send LAYOUTCOMMIT to a server that does FILE_SYNC writes.

The Linux pNFS client uses the 'forgetful client' model, so it will
never send LAYOUTRETURN on layout recalls either. The only case where we
send LAYOUTRETURN is when the file falls out of the inode cache.


> Is there any other way to verify that pnfs is used on client site?

The most direct way is to look for a TCP connection to the data server
using 'netstat -t'.

Cheers
  Trond

