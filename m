Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:44050 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978Ab1C2PwQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2011 11:52:16 -0400
From: <peter.staubach@emc.com>
To: <Zoltan.Menyhart@bull.net>, <chuck.lever@oracle.com>
CC: <linux-nfs@vger.kernel.org>
Date: Tue, 29 Mar 2011 11:50:36 -0400
Subject: RE: NFS v4 client blocks when using UDP protocol
Message-ID: <5E6794FC7B8FCA41A704019BE3C70E8B069D40C4@MX31A.corp.emc.com>
References: <EB0F26AF-C0DB-4861-ABB5-72E39CB38090@bull.net>
 <4D91ED79.4020302@bull.net>
 <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com> <4D91FA1D.1000206@bull.net>
In-Reply-To: <4D91FA1D.1000206@bull.net>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

It does talk about NFS over UDP, interestingly, but the text on page 25, indicates that the transport of choice MUST be one of the IETF-approved congestion control transport protocols, of which, UDP is not one.

Perhaps some clean up of RFC3530bis and RFC5661 could include removal of the UDP mentions.

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Menyhart Zoltan
Sent: Tuesday, March 29, 2011 11:26 AM
To: Chuck Lever
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v4 client blocks when using UDP protocol

Chuck Lever wrote:
> Zoltan-
>
> As far as I know, NFSv4 is not supported on UDP transports.
>Some of it may work, but no warrantee, either expressed or implied, is given.  :-)

Do you mean the Linux implementation?
Because the RFC 3530 speaks about how to do NFS v4 over UDP and UDP6.

Thank you,

Zoltan

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

