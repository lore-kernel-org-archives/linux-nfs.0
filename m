Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13963 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752572Ab0IANSE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 09:18:04 -0400
Subject: Re: [REGRESSION PATCH v2] NFS: let NFS_V4 and NFSD_V4 enforce
 CRYPTO
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        akpm@linux-foundation.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Randy Dunlap <randy.dunlap@oracle.com>, Neil Brown <neilb@suse.de>,
        Linus Torvalds <torvalds@linux-foundation.org>
In-Reply-To: <1283331170-11440-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20100830121022.GA14459@pengutronix.de>
	 <1283331170-11440-1-git-send-email-u.kleine-koenig@pengutronix.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Sep 2010 09:17:04 -0400
Message-ID: <1283347024.3184.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-01 at 10:52 +0200, Uwe Kleine-König wrote:
> Hello,
> 
> here comes a v2 of the patch that improves the commit log with a more
> detailed analysis of the breakage introduced by df486a2
> (= v2.6.36-rc2~34^2~1 BTW) and additionally undoes the "default y" for
> RPCSEC_GSS_KRB5.
> 
> So compared to the state before df486a2 the changes are:
> 
>         NFS_V4 selects CRYPTO
>         NFSD_V4 selects CRYPTO
> 	RPCSEC_GSS_KRB5 doesn't depend on EXPERIMENTAL anymore
> 	RPCSEC_GSS_KRB5 now depends on CRYPTO instead of selecting it
> 
> Best regards
> Uwe
> 
> ----------------------------->8----------------------------
> 
> This is a follow up to
> 
> 	df486a2 (NFS: Fix the selection of security flavours in Kconfig)
> 
> Before df486a2 NFS_V4 selected RPCSEC_GSS_KRB5 but didn't enforce the
> latter's dependency EXPERIMENTAL.  df486a2 removed RPCSEC_GSS_KRB5's
> dependency on EXPERIMENTAL but additionally let it depend on CRYPTO
> (instead of select CRYPTO before).  So it was still possible to have a
> config that has NFS_V4 but not RPCSEC_GSS_KRB5.  Moreover df486a2
> changed the dependency of NFS_V4 and NFSD_V4 on RPCSEC_GSS_KRB5 from

As I said, the fix is to remove that dependency. I have a fix for the
NFS client, but the server has more insidious dependencies on RPCSEC_GSS
due to a poorly designed SECINFO implementation.

Trond
