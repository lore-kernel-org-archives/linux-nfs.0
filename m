From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 21:23:07 +0200
Message-ID: <200907212123.08790.elendil@planet.nl>
References: <4A64EB1F.4000602@candelatech.com> <1248178527.5222.0.camel@heimdal.trondhjem.org> <4A65F184.5060802@candelatech.com> <1248196339.21343.8.camel@heimdal.trondhjem.org> <4A65FCB2.6080903@candelatech.com> <1248199140.21343.17.camel@heimdal.trondhjem.org> <4A660295.9020807@candelatech.com> <4A660295.9020807@candelatech.com> <1248200897.21343.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from Cpsmtpm-eml108.kpnxchange.com ([195.121.3.12]:54470 "EHLO
	CPSMTPM-EML108.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753081AbZGUTXK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 15:23:10 -0400
In-reply-To: <1248200897.21343.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> Ah... You have NFS_V4_1 enabled despite the Kconfig warning... Does the
> bug occur when you turn this off too?

Eh, no. In my case both client and server are 2.6.30 which did not yet 
have NFS_V4_1 (and in all my .31 configs I did disable it).
