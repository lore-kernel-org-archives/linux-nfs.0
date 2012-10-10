Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36151 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753584Ab2JJQGJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Oct 2012 12:06:09 -0400
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Wed, 10 Oct 2012 12:06:05 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9AFtcUg100646
	for <linux-nfs@vger.kernel.org>; Wed, 10 Oct 2012 12:04:53 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9AFtPq7022895
	for <linux-nfs@vger.kernel.org>; Wed, 10 Oct 2012 09:55:25 -0600
Date: Wed, 10 Oct 2012 10:54:54 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: David Werner <david.werner@iws.uni-stuttgart.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client
 openSUSE-11.4, 12.1 and 12.2)
Message-ID: <20121010155454.GA10050@us.ibm.com>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
 <20121010150448.GA12518@tindra.iws.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121010150448.GA12518@tindra.iws.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Werner [david.werner@iws.uni-stuttgart.de] wrote:
> Hi, 
> 
> to provide more details I made tcpdump of the 
> "touch .." on two hosts.  The outputfiles for looking in with wireshark
> & co are on: 
> 
> 	http://maultier.iws.uni-stuttgart.de:8080/nfs
> 
> But I do not understand much of nfs-protocol. 

I did take a quick look and didn't see anything wrong in the NFS trace.
Any syslog messages at the client. The ESTALE error must be made up at
the client.

Regards, Malahal.

