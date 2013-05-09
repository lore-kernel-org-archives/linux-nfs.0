Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:56639 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab3EIHsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 03:48:42 -0400
Received: from mailout-de.gmx.net ([10.1.76.27]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0LpiUy-1U6DV82U4s-00fT41 for
 <linux-nfs@vger.kernel.org>; Thu, 09 May 2013 09:48:40 +0200
Message-ID: <518B54D7.3090605@gmx.de>
Date: Thu, 09 May 2013 09:48:39 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: NFSD: unable to generate recoverydir name (-2).
References: <518AA163.2060906@gmx.de>
In-Reply-To: <518AA163.2060906@gmx.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/08/2013 09:02 PM, Toralf Förster wrote:
> 2013-05-08T20:43:19.416+02:00 n22 kernel: NFSD: unable to generate recoverydir name (-2).
> 2013-05-08T20:43:19.416+02:00 n22 kernel: NFSD: disabling legacy clientid tracking. Reboot recovery will not function correctly!
> 2013-05-08T20:43:19.416+02:00 n22 kernel: BUG: unable to handle kernel NULL pointer dereference at 000003c8

After this the NFS daemon itself at the host hangs completely.
The whole server has to be rebooted to get the NFS service back.

This behaviour is reproducible.

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
