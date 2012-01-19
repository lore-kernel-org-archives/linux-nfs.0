Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:59525 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab2ASRXS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jan 2012 12:23:18 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 19 Jan 2012 10:23:14 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 03855C90102
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2012 12:21:58 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0JHLurj285534
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2012 12:21:56 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0JHLgRU027086
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2012 10:21:42 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0JHLgBg027035
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jan 2012 10:21:42 -0700
Date: Thu, 19 Jan 2012 11:21:39 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 and high-availability
Message-ID: <20120119172139.GA3048@us.ibm.com>
References: <20120119135044.GS10362@ics.muni.cz>
 <201201191552.30691.misch@schwartzkopff.org>
 <20120119154951.GV10362@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120119154951.GV10362@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lukas Hejtmanek [xhejtman@ics.muni.cz] wrote:
> On Thu, Jan 19, 2012 at 03:52:30PM +0100, Michael Schwartzkopff wrote:
> > Yes. You can setup a NFSv4 cluster using a cluster manager like pacemaker.
> > 
> > Last time I set it up there were some issues with locking and timeouts. I 
> > don't know if this is already fixed. I'd have to try it myself again.
> 
> but this seems to be the mentioned server side HA mode. But can I move running
> client to another server (with anoter different IP)?

Not possible today. There are some patches out there for migration but
you will have to wait until some current problems with migration are
resolved and the solution gets accepted upstream.

