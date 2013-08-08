Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:55332 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964796Ab3HHQHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 12:07:16 -0400
Received: from [80.171.227.9] ([80.171.227.9]) by mail.gmx.com (mrgmx002)
 with ESMTPSA (Nemesis) id 0MTjua-1VXpJa3T8K-00QPPU for
 <linux-nfs@vger.kernel.org>; Thu, 08 Aug 2013 18:07:15 +0200
Message-ID: <5203C231.7030802@gmx.de>
Date: Thu, 08 Aug 2013 18:07:13 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: bisecting an NFS issue prevented by fs/nfsd/nfs4recover.c:1414
References: <5202AB04.9010006@gmx.de> <20130807202617.GA29924@umich.edu>
In-Reply-To: <20130807202617.GA29924@umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2013 10:26 PM, Jim Rees wrote:
> Toralf Förster wrote:
> 
>   I'm trying to bisect a NFS + EXT3/4 + loop device issue introduced
>   probably between v3.8 and v3.10. Unfortunately my test systems (2 user
>   mode linux images) often fails to reproduce the origin issue due to a
>   crash in at another place.
>   
>   Now I'm wondering if somebody can point me to (few) patches, which I could
>   just apply during bisect to avoid running into the "false" bug.
> 
> It could be this:
> 
> 7255e71 nfsd: fix oops when legacy_recdir_name_error is passed a -ENOENT error
> 
ofc - thx

-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
