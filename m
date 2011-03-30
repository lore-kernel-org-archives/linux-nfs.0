Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37087 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752799Ab1C3JAt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2011 05:00:49 -0400
Subject: Re: NFS v4 client blocks when using UDP protocol
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Tom Haynes <tdh@excfb.com>
Cc: peter.staubach@emc.com, Zoltan.Menyhart@bull.net, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
In-Reply-To: <20110330001232.GB19700@adept.internal.excfb.com>
References: <EB0F26AF-C0DB-4861-ABB5-72E39CB38090@bull.net>
	 <4D91ED79.4020302@bull.net>
	 <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com>
	 <4D91FA1D.1000206@bull.net>
	 <5E6794FC7B8FCA41A704019BE3C70E8B069D40C4@MX31A.corp.emc.com>
	 <20110330001232.GB19700@adept.internal.excfb.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 11:00:47 +0200
Message-ID: <1301475647.7654.34.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-29 at 19:12 -0500, Tom Haynes wrote:
> On Tue, Mar 29, 2011 at 11:50:36AM -0400, peter.staubach@emc.com wrote:
> > It does talk about NFS over UDP, interestingly, but the text on page 25, indicates that the transport of choice MUST be one of the IETF-approved congestion control transport protocols, of which, UDP is not one.
> > 
> > Perhaps some clean up of RFC3530bis and RFC5661 could include removal of the UDP mentions.
> 
> The text in 3530bis could be made to match that in 5661:
> 
>    It is permissible for a connectionless transport to be used under
>    NFSv4.1; however, reliable and in-order delivery of data combined
>    with congestion control by the connectionless transport is REQUIRED.
>    As a consequence, UDP by itself MUST NOT be used as an NFSv4.1
>    transport.  NFSv4.1 assumes that a client transport address and
>    server transport address used to send data over a transport together
>    constitute a connection, even if the underlying transport eschews the
>    concept of a connection.
> 
> But as we can see 5661 is very strong.

I think Peter is referring to the text in section 2.2 and section 17.2
which describes the format for netids and universal addresses
specifically for the UDP case.

I agree with Peter's suggestion that we should just delete that text.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

