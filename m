From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Wed, 04 Feb 2009 13:47:11 -0500
Message-ID: <1233773231.7161.51.camel@heimdal.trondhjem.org>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
	 <1233699391.7161.11.camel@heimdal.trondhjem.org>
	 <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com>
	 <1233771633.7161.35.camel@heimdal.trondhjem.org>
	 <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:42042 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760910AbZBDSrT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Feb 2009 13:47:19 -0500
In-Reply-To: <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-04 at 13:44 -0500, Chuck Lever wrote:
> Right.  So, then, can nfs_match_client() use the same address  
> comparison method as nfs_find_client()?  I'm inclined to think  
> nfs_match_client() can use a more straightforward address comparison  
> method.

It could. We should certainly be checking that the sa_family field
matches...

Trond

