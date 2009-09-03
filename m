Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42225 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997AbZICSzh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 14:55:37 -0400
From: Andreas Gruenbacher <agruen@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 20:55:32 +0200
Cc: Steve French <smfrench@gmail.com>, Ondrej Valousek <webserv@s3group.cz>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, ffilzlnx@linux.vnet.ibm.com, jra@samba.org
References: <524f69650909021156lf181c17uf800eba7c35a6f45@mail.gmail.com> <524f69650909030654u7653d410kd5cde25ec223a87@mail.gmail.com> <1251986968.18338.36.camel@heimdal.trondhjem.org>
In-Reply-To: <1251986968.18338.36.camel@heimdal.trondhjem.org>
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <200909032055.33380.agruen@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thursday, 3 September 2009 16:09:28 Trond Myklebust wrote:
> The main problem has been finding developers with an interest, and with
> enough time on their hands. Andreas Gruenbacher started working on NFSv4
> acls, but due to his time constraints, his work ended up getting farmed
> out to a developer in SGI, and consequently ended up in a black hole
> somewhere...

Indeed ... I transferred as much knowledge as I could to a group of SGI 
engineers who were then working on the project for a while. Unfortunately 
then the whole group was laid off (for unrelated reasons). I could not find a 
sponsor for continuing from there since.

The open issues in the project include some research (e.g., figuring out how 
Windows applications behave in practice when using Linux NFSv4 ACLs -- this 
is necessary to make a few implementation decisions which the overall design 
has left open), and some more implementation / testing / documentation work.

Thanks,
Andreas
