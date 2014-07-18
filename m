Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:54618 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755894AbaGRQuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2014 12:50:40 -0400
Message-ID: <53C9505D.80601@gmx.de>
Date: Fri, 18 Jul 2014 18:50:37 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
References: <53C10EAA.2000802@gmx.de> <53C12A93.3040803@gmail.com> <20140716185724.GC2397@fieldses.org> <20140717202721.GG30442@fieldses.org> <53C949DC.5060008@gmx.de>
In-Reply-To: <53C949DC.5060008@gmx.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/18/2014 06:22 PM, Toralf Förster wrote:
> I can now try with kzalloc, but due to the nature of this issue I think, that the absence of this crash - even after 2-3 hours - doesn't mean by 100%, that kzalloc fixed it, or ?

Well, next crash (with kzalloc patch) happened after 20 minutes ...


-- 
Toralf

