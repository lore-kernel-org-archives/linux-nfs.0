Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:39919 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755659Ab2FZMnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2012 08:43:51 -0400
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Tue, 26 Jun 2012 14:43:48 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <1340632000.9620.7.camel@lade.trondhjem.org>
Message-ID: <20120626124348.48490@gmx.net>
MIME-Version: 1.0
References: <20120625074306.48500@gmx.net>
 <1340632000.9620.7.camel@lade.trondhjem.org>
Subject: Re: LAYOUTCOMMIT/LAYOUTRETURN
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

thanks for your answers.

But how do i find out, whether the server is using FILE_SYNC?
Is there any other mode like "FILE_ASYNC"?

And if the server is using FILE_SYNC, how does it get LAYOUTCOMMIT?


Thanks in advance


Johannes


-------- Original-Nachricht --------
> Datum: Mon, 25 Jun 2012 09:46:40 -0400
> Von: Trond Myklebust <trond.myklebust@fys.uio.no>
> An: Johannes Schild <JSchild@gmx.de>
> CC: linux-nfs@vger.kernel.org
> Betreff: Re: LAYOUTCOMMIT/LAYOUTRETURN

> On Mon, 2012-06-25 at 09:43 +0200, Johannes Schild wrote:
> > Hi Guys,
> > 
> > i have another question on pNFS. I looked at my Wireshark protocols,
> while i used the FILE-Layout, and i wondered why i have no
> LAYOUTCOMMIT/LAYOUTRETURN statements in my protocols.
> > I transfered one file to my storage server (NETAPP Simulator 8.1 C-Mode)
> and i only got a LAYOUTGET.
> > 
> > cat /proc/self/mountstats | grep LAYOUT says:
> > nfsv4:
> bm0=0xfafe8fff,bml=0x60fdfffe,acl=0x3,sessions,pnfs=LAYOUT_NFSV4_1_FILES
> >     LAYOUTGET: 1 1 0 216 236 0 1 1
> >  LAYOUTCOMMIT: 0 0 0 0 0 0 0 0
> >  LAYOUTRETURN: 0 0 0 0 0 0 0 0 
> 
> A pNFS client should never send LAYOUTCOMMIT to a server that does
> FILE_SYNC writes.
> 
> The Linux pNFS client uses the 'forgetful client' model, so it will
> never send LAYOUTRETURN on layout recalls either. The only case where we
> send LAYOUTRETURN is when the file falls out of the inode cache.
> 
> 
> > Is there any other way to verify that pnfs is used on client site?
> 
> The most direct way is to look for a TCP connection to the data server
> using 'netstat -t'.
> 
> Cheers
>   Trond
> 

-- 
NEU: FreePhone 3-fach-Flat mit kostenlosem Smartphone!                                  
Jetzt informieren: http://mobile.1und1.de/?ac=OM.PW.PW003K20328T7073a
