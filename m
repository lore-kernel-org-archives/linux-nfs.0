Return-Path: linux-nfs-owner@vger.kernel.org
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:45291 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab2CVROS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2012 13:14:18 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.3) with ESMTP id q2MHEGVx020489
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 18:14:16 +0100
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id q2MHEGPF028617
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 18:14:16 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia2.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.2) with SMTP id q2MHEFuc007528
	for <linux-nfs@vger.kernel.org>; Thu, 22 Mar 2012 18:14:15 +0100
Message-ID: <4F6B5DE7.5070900@cea.fr>
Date: Thu, 22 Mar 2012 18:14:15 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: READDIRPLUS3 and NFS3ERR_BAD_COOKIE
References: <4F6B1EF3.2000200@cea.fr> <1332436029.8976.2.camel@lade.trondhjem.org>
In-Reply-To: <1332436029.8976.2.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond a écrit :
>
> Does bonnie++ check the return value of readdir? There is no easy way
> for the client to recover when the server returns BAD_COOKIE, so we
> should be passing that error back to the application
Thanks for your reply, Trond.
No, it does not. It uses the readdir() call that takes a directory as 
argument and returns a pointer to an array of struct dirents.
When bad cookie is sent back to the application, which error will it be. 
I saw errno = 523 ? Is this correct ?

    Regards

       Philippe
