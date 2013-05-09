Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:55794 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab3EIQSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 12:18:10 -0400
Received: from mailout-de.gmx.net ([10.1.76.12]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0M0ei8-1UH0gh0W5O-00untm for
 <linux-nfs@vger.kernel.org>; Thu, 09 May 2013 18:18:09 +0200
Message-ID: <518BCC3E.8060501@gmx.de>
Date: Thu, 09 May 2013 18:18:06 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: NFSD: unable to generate recoverydir name (-2).
References: <518AA163.2060906@gmx.de> <518B54D7.3090605@gmx.de> <20130509083515.1f138786@tlielax.poochiereds.net>
In-Reply-To: <20130509083515.1f138786@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/09/2013 02:35 PM, Jeff Layton wrote:
> Nice catch -- thanks for reporting this. I see the bug and have a patch
> that I'll send along in a bit. It's fairly straightforward but if you
> can test it, then that would be wonderful.
tested - works fine so far :-)

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
