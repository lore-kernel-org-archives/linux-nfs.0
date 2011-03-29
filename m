Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63604 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab1C2Pqp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Mar 2011 11:46:45 -0400
Subject: Re: NFS v4 client blocks when using UDP protocol
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4D91FA1D.1000206@bull.net>
Date: Tue, 29 Mar 2011 11:46:39 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <40935036-45B1-4B12-BBF4-D4FEADF29FE7@oracle.com>
References: <EB0F26AF-C0DB-4861-ABB5-72E39CB38090@bull.net> <4D91ED79.4020302@bull.net> <4A05F533-1BE6-4DFC-BC53-9392DA8BED76@oracle.com> <4D91FA1D.1000206@bull.net>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 29, 2011, at 11:26 AM, Menyhart Zoltan wrote:

> Chuck Lever wrote:
>> Zoltan-
>> 
>> As far as I know, NFSv4 is not supported on UDP transports.
>> Some of it may work, but no warrantee, either expressed or implied, is given.  :-)
> 
> Do you mean the Linux implementation?
> Because the RFC 3530 speaks about how to do NFS v4 over UDP and UDP6.

My reading of 3530 is that NFSv4 is not allowed over non-stream transports like UDP.  The Linux implementation does not support NFSv4 over UDP, even though it allows you to try it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




