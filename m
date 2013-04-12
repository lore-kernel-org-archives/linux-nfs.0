Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61288 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743Ab3DLVts convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Apr 2013 17:49:48 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [nfsv4] unsupported mandatory server features
Date: Fri, 12 Apr 2013 21:49:39 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA92871330A@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130412210100.GP7081@fieldses.org>
In-Reply-To: <20130412210100.GP7081@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf
> Of J. Bruce Fields
> Sent: Friday, April 12, 2013 5:01 PM
> To: nfsv4@ietf.org
> Cc: linux-nfs@vger.kernel.org
> Subject: [nfsv4] unsupported mandatory server features
> 
> I'm expecting to turn on basic 4.1 support by default on the Linux server
> before supporting two mandatory 4.1 features, and looking for advice on
> handling that without too much pain to future clients.  I suspect I'm not the
> only server in this situation; anyone know what others are doing?
> 
> The features are:
> 
> 	- State protection (SSV and MACH_CRED): I'm currently returning
> 	  SERVERFAULT on EXCHANGE_ID's that request this, but this isn't
> 	  really what SERVERFAULT is for.
> 
> 	  I'm inclined to switch to ENC_ALG_UNSUPP; that leaves future
> 	  clients unable to distinguish between servers lacking SSV
> 	  entirely from those lacking support for a particular
> 	  algorithm, but in practice I think they'd handle both in the
> 	  same way anyway.

Why not just reply with NFS4ERR_ENC_ALG_UNSUPP for SP4_SSV (as you suggest) and return an empty spo_must_allow, and minimal spo_must_enforce sets for SP4_MACH_CRED?

By minimal spo_must_enforce, I mean EXCHANGE_ID, CREATE_SESSION, DESTROY_SESSION, BIND_CONN_TO_SESSION, and DESTROY_CLIENTID. I'm assuming that you default to checking the principal name for those anyway since NFSv4 requires it for the corresponding SETCLIENTID/CONFIRM?

> 	- GSS on the backchannel: currently CREATE_SESSION or
> 	  BACKCHANNEL_CTL will succeed but SEQUENCE will start returning
> 	  with the CB_DOWN flag set.  I would rather return an error
> 	  immediately than make the client guess what's going on in
> 	  recovery.
> 
> 	  Could I get away with returning ENC_ALG_UNSUPP here too?  It's
> 	  not entirely logical, but it's also currently illegal for
> 	  these two operations so its use wouldn't be confused with some
> 	  other.

Why not return NFS4ERR_NOENT to tell the client that the handle does not exist?

> Of course my preference would be just to support these features, but given
> resource limitations, the lack of interest, and the lack of any implementation
> to test against, that doesn't look likely to happen in the near future.
> 
> --b.
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
