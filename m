From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 15:54:36 -0400
Message-ID: <1248206076.21343.30.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
	 <1248178527.5222.0.camel@heimdal.trondhjem.org>
	 <4A65F184.5060802@candelatech.com>
	 <1248196339.21343.8.camel@heimdal.trondhjem.org>
	 <4A65FCB2.6080903@candelatech.com>
	 <1248199140.21343.17.camel@heimdal.trondhjem.org>
	 <4A660295.9020807@candelatech.com> <4A660295.9020807@candelatech.com>
	 <1248200897.21343.19.camel@heimdal.trondhjem.org>
	 <200907212123.08790.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:36907 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755291AbZGUTyk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 15:54:40 -0400
In-Reply-To: <200907212123.08790.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-07-21 at 21:23 +0200, Frans Pop wrote:
> Trond Myklebust wrote:
> > Ah... You have NFS_V4_1 enabled despite the Kconfig warning... Does the
> > bug occur when you turn this off too?
> 
> Eh, no. In my case both client and server are 2.6.30 which did not yet 
> have NFS_V4_1 (and in all my .31 configs I did disable it).

...and you are seeing the state manager running when you try to mount an
NFSv4 partition using the 2.6.30 client?

Trond

