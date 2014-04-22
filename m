Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58356 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754420AbaDVKM1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 06:12:27 -0400
Message-ID: <53563F16.80809@fastmail.fm>
Date: Tue, 22 Apr 2014 12:06:14 +0200
From: Bernd Schubert <bernd.schubert@fastmail.fm>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: nfsd4_decode_create: Fix a possible NULL pointer
 dereference
References: <lis0kj$kaj$1@ger.gmane.org> <53548EF2.40408@gmail.com>
In-Reply-To: <53548EF2.40408@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> cr_linkname maybe a path contains '/', or '.',
> check_filename will return error nfserr_badname for those path.
> 
> IMO, just check whether the length is zero as,
> 
> if (create->cr_linklen == 0)
>     return nfserr_inval;
> 


Hmm, right, checking for a '/' not right here. Checking if link-name is
"." or ".." isn't required, but shouldn't hurt either. But on the other
hand we can leave that to the underlying file system.


Thanks for your review!

Bernd
