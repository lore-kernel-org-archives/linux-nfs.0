Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:55367 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755186AbaGSJ1w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Jul 2014 05:27:52 -0400
Message-ID: <53CA3A0E.4040400@gmx.de>
Date: Sat, 19 Jul 2014 11:27:42 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
References: <53C10EAA.2000802@gmx.de>	<53C12A93.3040803@gmail.com>	<20140716185724.GC2397@fieldses.org>	<20140717202721.GG30442@fieldses.org>	<53C949DC.5060008@gmx.de>	<53C9505D.80601@gmx.de> <CAB6yy37-_aC83yS5JaaAbX4-qKWko-pjqSRaipZ3reVnMD=aAg@mail.gmail.com>
In-Reply-To: <CAB6yy37-_aC83yS5JaaAbX4-qKWko-pjqSRaipZ3reVnMD=aAg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/19/2014 05:23 AM, Kinglong Mee wrote:
> Lock file success, nfsd will copy stateid to the union, but the value
> also influence denied.
> If on x86_64 platform, only influence the len in xdr_netobj,
> but on i686 platform, will influence the len and the data in xdr_netobj.
> So, the problem only appears on i686 platform.

OT, but wouldn't this be a good example for the coverity people to check for it too ?


-- 
Toralf

