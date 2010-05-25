Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:40937 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178Ab0EYNg5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 09:36:57 -0400
Received: from d12nrmr1507.megacenter.de.ibm.com (d12nrmr1507.megacenter.de.ibm.com [9.149.167.1])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o4PDauTm013908
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 13:36:56 GMT
Received: from d12av06.megacenter.de.ibm.com (d12av06.megacenter.de.ibm.com [9.149.165.230])
	by d12nrmr1507.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4PDauBM1286276
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 15:36:56 +0200
Received: from d12av06.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av06.megacenter.de.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4PDatKT030351
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 15:36:55 +0200
Received: from d12ml072.megacenter.de.ibm.com (d12ml072.megacenter.de.ibm.com [9.149.166.115])
	by d12av06.megacenter.de.ibm.com (8.14.3/8.13.1/NCO v10.0 AVin) with ESMTP id o4PDatg0030348
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 15:36:55 +0200
Subject: Profiling knfsd
To: linux-nfs@vger.kernel.org
Message-ID: <OF356BDCDD.AFFB6E1B-ONC125772E.004AC232-C125772E.004AC9B8@de.ibm.com>
From: Eric Veith1 <eric.veith@de.ibm.com>
Date: Tue, 25 May 2010 15:36:53 +0200
Content-type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hello everybody,

I'm facing the somewhat difficult task of looking under the hood of the
knfsd and profiling its behaviour on WRITE/COMMIT calls. Basically, I'd
like to answer the following questions:

- What amount of payload is comming in?
- What WRITE flags are set (UNSTABLE/DATA_SYNC/FILE_SYNC)?
- What happens to the incoming RPCs (are they stored in a queue, or cached
if UNSTABLE is set? If yes, what is the queue/cache size)?
- What does the nfsd write out to disk?
- How many NFS I/O operations are a kernel VFS (?) operation, and how many
FS IOPs does this make?

Regarding the last question, I already have a way of finding out what I/O
operations containing what payload are done with what delay.

I'm a little at loss here because I have only a very vague idea of where to
look. I though using systemtap and tapping some functions would give me
answers to the questions above. Could somebody give me please some
pointers, be it function names, header files, or a general idea of the call
flow a NFS WRITE packet creates from being received over a socket until it
is written out to disk?

Thank you very much in advance.

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

