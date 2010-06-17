From: Raimund Eimann <raimund-47KOqKphs/PNLxjTenLetw@public.gmane.org>
Subject: Please help: half working NFS / weird permissions issue
Date: Thu, 17 Jun 2010 07:28:44 +0200
Message-ID: <d5417bd9b9142da098b1c0df06b7a294@localhost>
Reply-To: raimund-47KOqKphs/PNLxjTenLetw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.65.112.156] ([195.65.112.156]:60270 "EHLO
	mail.ch.busy-byte.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab0FQFg5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 01:36:57 -0400
Received: from mail.ch.busy-byte.org (localhost [127.0.0.1])
	by mail.ch.busy-byte.org (Postfix) with ESMTP id A8E5A1605F
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 07:28:44 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've been using NFS on SuSE/openSuSE Linux for 10 years now and know that
UID/GID must match the server to have the same permissions on the NFS
client box.

I've exported ~10 directories on the server. When the client box still ran
openSuSE 11.2, everything was ok.

Recently, I installed the client with Ubuntu 10.04 64 bit, and now NFS is
partly broken, without making any changes to the server:

* I'm running openLDAP to distribute user information, so UIDs and GIDs
are identical on both the client and the server.

* for certain groups, I get permission problems, for others everything is
fine:

  * I have a openLDAP-provided group bbusers which all users belong to.
Home dir perms are <username>:bbusers with either 750 of even 700
permissions on most subdirectoies. No problems here.

  * I have another groups provided by openLDAP called bbpcit_p and
bbpict_r and some directories that uses these groups on an NFS export
mounted on the client:

    raimund@nfsclient:/nfs/p$ l -d Garten Scans
    drwxr-x--- 3 root bbpict_p 36864 2009-09-13 18:46 Garten/
    drwxr-x--- 9 root bbpict_r  4096 2008-12-04 21:36 Scans/

    Numeric UIDs/GIDs here:

    raimund@jupiter:/nfs/p$ l -dn Garten Scans
    drwxr-x--- 3 0 1017 36864 2009-09-13 18:46 Garten/
    drwxr-x--- 9 0 1007  4096 2008-12-04 21:36 Scans/

    I can "cd Scans" without problems, but I can't "cd Garten", I get
"permission denied" If I try the latter. I am a member of both groups:

    raimund@jupiter:/nfs/p$ id | tr "," "\n" |grep bbpict_
    1007(bbpict_r)
    1017(bbpict_p)

  * I am sure this is an NFS problem, because when I create directories
with the same permissions/groups an a local filesystem, everything works
just fine. When I SSH into the server I can enter the directories just fine
as well.

  * If I do a "sg bbict_p", my default group changes from bbusers
(GID=1000) to bbpict_p. After this procedure I can "cd Garten".

  * Could it be that the NFS-client somehow ignores higher GIDs? Groups
with GIDs>=1012 seem to suffer from this problem more often, but I haven't
tested them all. Which config file might contain restrictions like this?

I am pretty much out of ideas on this problem. I would *greatly*
appreciate hints on how to solve it. Please, NFS-experts, enlighten me!

Cheers,
Raimund

