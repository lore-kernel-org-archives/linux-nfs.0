Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:52891 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896Ab0EZNNT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 09:13:19 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.1/8.13.1) with ESMTP id o4QDDCdQ026411
	for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 13:13:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4QDDCwR929912
	for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 15:13:12 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4QDDCo3029443
	for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 15:13:12 +0200
In-Reply-To: <20100525212312.GM7085@fieldses.org>
References: <OF356BDCDD.AFFB6E1B-ONC125772E.004AC232-C125772E.004AC9B8@de.ibm.com> <20100525212312.GM7085@fieldses.org>
Subject: Re: Profiling knfsd
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Message-ID: <OF7CD4B843.40997B21-ONC125772F.0047E6AA-C125772F.00489D77@de.ibm.com>
From: Eric Veith1 <eric.veith@de.ibm.com>
Date: Wed, 26 May 2010 15:13:09 +0200
Content-type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce,

thanks for your answer!

"J. Bruce Fields" <bfields@fieldses.org> wrote on 05/25/2010 11:23:12 PM:
> Unfortunately I don't know of any really good documentation; you
> probably just have to dive in, read the code, and experiment.

In the meantime, I've been able to follow the call path quite a bit using
systemtap. Whoohoo, what a nice tool for this. Where I still have problems
is with anything below the actula fs/nfsd/nfsproc.c code, i.e. the VFS
calls and where a chunk of data is actually handled over to the FS.

> What's the high-level question you're trying to answer?

In a short summary: "How many I/O operations are caused by a NFS WRITE
call?" It includes things like following a WRITE call through until it
reaches the FS and the storage below and finding out whether the Kernel or
the FS (which is GPFS) do caching on unstable WRITEs.

The question originates from a performance problem I was once facing where
the DS' controller couldn't handle the client's writeout behaviour when
streaming a very large file. We more or less guessed the DS part, and now
I'd really like to see where the bottleneck is. I'd like to follow a WRITE
through the whole kernel through GPFS until it reaches the DS' controller,
see how many IOPs this WRITE really causes, what the latencies are and
whether there's a write queue that is painfully full at some point.

TIA!

                  Eric

--
Eric MSP Veith <eric.veith@de.ibm.com>
Hechtsheimer Str. 2
DE-55131 Mainz
Germany

IBM Deutschland GmbH
Vorsitzender des Aufsichtsrats: Erich Clementi
Geschäftsführung: Martin Jetter (Vorsitzender), Reinhard Reschke, Christoph
Grandpierre, Matthias Hartmann, Michael Diemer, Martina Koederitz
Sitz der Gesellschaft: Stuttgart
Registergericht: Amtsgericht Stuttgart, HRB 14562
WEEE-Reg.-Nr. DE 99369940

