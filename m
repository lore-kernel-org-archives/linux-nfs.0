Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37893 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab3FFOtF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jun 2013 10:49:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: NFS4+KRB5 trouble in Kernel >3.8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <koq2ie$gtu$1@ultimate100.geggus.net>
Date: Thu, 6 Jun 2013 10:48:54 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <DBA14DEF-59CE-4068-B2B8-7F208F2EBA22@oracle.com>
References: <koq2ie$gtu$1@ultimate100.geggus.net>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 6, 2013, at 9:24 AM, Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> Hello,
> 
> seems I have been bitten again by the same Problem as back in November
> (http://comments.gmane.org/gmane.linux.nfs/52916).
> 
> Well, at least the symptoms are the same. The problem is almost
> certainly another one.
> 
> In recent kernels (e.g. 3.9.4) again my mount seems to hang infinitely:
> 
> mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/tmp 
> 
> This time I immediately tried to bisect this,

Perhaps you could try enabling debugging first to see where the hang occurs.

  $ sudo rpcdebug -m nfs -s all

then add "-vvv" on the rpc.gssd command line.  Try your mount again, and look in /var/log/messages.


> but what happens is that half
> the way down bisecting the symptoms change. The mount does not hang anymore,
> but I get "access denied" now:
> 
> ~/ # mount -t nfs4 -o sec=krb5 testsrv:/storage /mnt/tmp
> mount.nfs4: access denied by server while mounting testsrv:/storage
> 
> So how to continue bisecting? Should I mark this as good or bad?
> 
> Here is the output of "git bisect log" so far:
> 
> git bisect start
> # good: [dbf932a9b316d5b29b3e220e5a30e7a165ad2992] Linux 3.8.13
> git bisect good dbf932a9b316d5b29b3e220e5a30e7a165ad2992
> # bad: [0bfd8ffeff9dda08c69381d65c72e0aa58706ef6] Linux 3.9.4
> git bisect bad 0bfd8ffeff9dda08c69381d65c72e0aa58706ef6
> # good: [19f949f52599ba7c3f67a5897ac6be14bfcb1200] Linux 3.8
> git bisect good 19f949f52599ba7c3f67a5897ac6be14bfcb1200
> # good: [ef53d16cded7f89b3843b7a96970dab897843ea5] ksm: allocate roots when needed
> git bisect good ef53d16cded7f89b3843b7a96970dab897843ea5
> 
> I did not mark the current state with either good or bad yet.
> 
> Regards
> 
> Sven
> 
> -- 
> Software patents are the software project equivalent of land mines: Each
> design decision carries a risk of stepping on a patent, which can destroy
> your project. (Richard M. Stallman)
> /me is giggls@ircnet, http://sven.gegg.us/ on the Web
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




