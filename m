Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmfepi202.cox.net ([68.230.241.206]:41797 "EHLO
	eastrmfepi202.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605Ab1C3A3W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2011 20:29:22 -0400
Date: Tue, 29 Mar 2011 19:12:32 -0500
From: Tom Haynes <tdh@excfb.com>
To: peter.staubach@emc.com
Cc: Zoltan.Menyhart@bull.net, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: NFS v4 client blocks when using UDP protocol
Message-ID: <20110330001232.GB19700@adept.internal.excfb.com>
References: <EB0F26AF-C0DB-4861-ABB5-72E39CB38090@bull.net>
 <4D91ED79.4020302@bull.net>
 <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com>
 <4D91FA1D.1000206@bull.net>
 <5E6794FC7B8FCA41A704019BE3C70E8B069D40C4@MX31A.corp.emc.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B069D40C4@MX31A.corp.emc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 29, 2011 at 11:50:36AM -0400, peter.staubach@emc.com wrote:
> It does talk about NFS over UDP, interestingly, but the text on page 25, indicates that the transport of choice MUST be one of the IETF-approved congestion control transport protocols, of which, UDP is not one.
> 
> Perhaps some clean up of RFC3530bis and RFC5661 could include removal of the UDP mentions.

The text in 3530bis could be made to match that in 5661:

   It is permissible for a connectionless transport to be used under
   NFSv4.1; however, reliable and in-order delivery of data combined
   with congestion control by the connectionless transport is REQUIRED.
   As a consequence, UDP by itself MUST NOT be used as an NFSv4.1
   transport.  NFSv4.1 assumes that a client transport address and
   server transport address used to send data over a transport together
   constitute a connection, even if the underlying transport eschews the
   concept of a connection.

But as we can see 5661 is very strong.

> 
> 		ps
> 
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Menyhart Zoltan
> Sent: Tuesday, March 29, 2011 11:26 AM
> To: Chuck Lever
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS v4 client blocks when using UDP protocol
> 
> Chuck Lever wrote:
> > Zoltan-
> >
> > As far as I know, NFSv4 is not supported on UDP transports.
> >Some of it may work, but no warrantee, either expressed or implied, is given.  :-)
> 
> Do you mean the Linux implementation?
> Because the RFC 3530 speaks about how to do NFS v4 over UDP and UDP6.
> 
> Thank you,
> 
> Zoltan
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Tom Haynes
ex-cfb
