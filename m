Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11106 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753078Ab3EIMfU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 08:35:20 -0400
Date: Thu, 9 May 2013 08:35:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Toralf =?ISO-8859-1?B?RvZyc3Rlcg==?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: NFSD: unable to generate recoverydir name (-2).
Message-ID: <20130509083515.1f138786@tlielax.poochiereds.net>
In-Reply-To: <518B54D7.3090605@gmx.de>
References: <518AA163.2060906@gmx.de>
	<518B54D7.3090605@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 09 May 2013 09:48:39 +0200
Toralf Förster <toralf.foerster@gmx.de> wrote:

> On 05/08/2013 09:02 PM, Toralf Förster wrote:
> > 2013-05-08T20:43:19.416+02:00 n22 kernel: NFSD: unable to generate recoverydir name (-2).
> > 2013-05-08T20:43:19.416+02:00 n22 kernel: NFSD: disabling legacy clientid tracking. Reboot recovery will not function correctly!
> > 2013-05-08T20:43:19.416+02:00 n22 kernel: BUG: unable to handle kernel NULL pointer dereference at 000003c8
> 
> After this the NFS daemon itself at the host hangs completely.
> The whole server has to be rebooted to get the NFS service back.
> 
> This behaviour is reproducible.
> 

Nice catch -- thanks for reporting this. I see the bug and have a patch
that I'll send along in a bit. It's fairly straightforward but if you
can test it, then that would be wonderful.

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>
