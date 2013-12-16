Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:51142 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab3LPOvJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Dec 2013 09:51:09 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 16 Dec 2013 07:51:08 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 0F9871FF001A
	for <linux-nfs@vger.kernel.org>; Mon, 16 Dec 2013 07:50:43 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBGEp69D7799050
	for <linux-nfs@vger.kernel.org>; Mon, 16 Dec 2013 15:51:06 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBGEp6Zo006490
	for <linux-nfs@vger.kernel.org>; Mon, 16 Dec 2013 07:51:06 -0700
Date: Mon, 16 Dec 2013 08:51:04 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Manfred Lemke <Manfred.Lemke@ptvgroup.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 replica support in Debian 7.2 (Wheezy, main)?
Message-ID: <20131216145104.GA6587@us.ibm.com>
References: <B22C0EEA6386B642830CA194B24C29CD066F32C87A@SKA-WN-E25CEX.ptvag.ptv.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <B22C0EEA6386B642830CA194B24C29CD066F32C87A@SKA-WN-E25CEX.ptvag.ptv.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Manfred Lemke [Manfred.Lemke@ptvgroup.com] wrote:
> Perhaps someone can help me here,
> 
> I'm trying to use the "replicas=" feature in NFSv4 under Debian 7.2. It seems the client is unable to switch to an alternate source and instead simply blocks.
> 
> Can anyone give me a hand and tell me if (and where) I can find packages to support the replica feature of NFSv4?

Linux NFS client doesn't support replication feature yet.

Regards, Malahal.

