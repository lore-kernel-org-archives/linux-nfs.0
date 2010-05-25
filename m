Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43833 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758533Ab0EYVXO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 17:23:14 -0400
Date: Tue, 25 May 2010 17:23:12 -0400
To: Eric Veith1 <eric.veith@de.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Profiling knfsd
Message-ID: <20100525212312.GM7085@fieldses.org>
References: <OF356BDCDD.AFFB6E1B-ONC125772E.004AC232-C125772E.004AC9B8@de.ibm.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <OF356BDCDD.AFFB6E1B-ONC125772E.004AC232-C125772E.004AC9B8@de.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 03:36:53PM +0200, Eric Veith1 wrote:
> 
> Hello everybody,
> 
> I'm facing the somewhat difficult task of looking under the hood of the
> knfsd and profiling its behaviour on WRITE/COMMIT calls. Basically, I'd
> like to answer the following questions:
> 
> - What amount of payload is comming in?
> - What WRITE flags are set (UNSTABLE/DATA_SYNC/FILE_SYNC)?
> - What happens to the incoming RPCs (are they stored in a queue, or cached
> if UNSTABLE is set? If yes, what is the queue/cache size)?
> - What does the nfsd write out to disk?
> - How many NFS I/O operations are a kernel VFS (?) operation, and how many
> FS IOPs does this make?
> 
> Regarding the last question, I already have a way of finding out what I/O
> operations containing what payload are done with what delay.
> 
> I'm a little at loss here because I have only a very vague idea of where to
> look. I though using systemtap and tapping some functions would give me
> answers to the questions above. Could somebody give me please some
> pointers, be it function names, header files, or a general idea of the call
> flow a NFS WRITE packet creates from being received over a socket until it
> is written out to disk?

There's a little bit of information in /proc/net/rpc/nfsd and
/proc/fs/nfsd/pool_stats.

Greg Banks had some patches to improve nfsd statistics (and provide some
of the information you're asking for) that never got merged.  If someone
wanted to take over the task of forward-porting them and fixing the
final problems, that might be one way to be to learn the code in
question.

Unfortunately I don't know of any really good documentation; you
probably just have to dive in, read the code, and experiment.

What's the high-level question you're trying to answer?

--b.

> 
> Thank you very much in advance.
> 
>                   Eric
> 
> --
> Eric MSP Veith <eric.veith@de.ibm.com>
> Hechtsheimer Str. 2
> DE-55131 Mainz
> Germany
> 
> IBM Deutschland GmbH
> Vorsitzender des Aufsichtsrats: Erich Clementi
> Geschäftsführung: Martin Jetter (Vorsitzender), Reinhard Reschke, Christoph
> Grandpierre, Matthias Hartmann, Michael Diemer, Martina Koederitz
> Sitz der Gesellschaft: Stuttgart
> Registergericht: Amtsgericht Stuttgart, HRB 14562
> WEEE-Reg.-Nr. DE 99369940
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
