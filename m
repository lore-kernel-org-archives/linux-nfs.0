Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:2054 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986Ab3KRSh7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 13:37:59 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix kbuild errors due to missing symbols
Date: Mon, 18 Nov 2013 18:37:56 +0000
Message-ID: <3D379D5B-C02D-4AAD-9A21-08A70BA3AF48@netapp.com>
References: <1384554636-25330-1-git-send-email-bjschuma@netapp.com>
 <1384557410.3222.2.camel@leira.trondhjem.org> <528A5360.4000206@netapp.com>
In-Reply-To: <528A5360.4000206@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 18, 2013, at 12:50, Anna Schumaker <bjschuma@netapp.com> wrote:
> 
> It's a poorly phrased commit message, actually.  I meant that just setting CONFIG_NFS_USE_LEGACY_DNS=y causes build problems, and then setting CONFIG_NFS_V4=n causes a different set of errors.

Ah. OK, now I see why you need it. The code in fs/nfs/super.c relies on it when !defined CONFIG_NFS_V4.

You also need to move the CONFIG_NFS_V4_SECURITY_LABEL section outside the CONFIG_NFS_V4, since fs/nfs/dir.c and others need the dummy nfs4_label_alloc and nfs4_label_free inline functions (see Stephen Rothwell
’s email).


--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

