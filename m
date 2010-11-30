Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25142 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214Ab0K3PVI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 10:21:08 -0500
Subject: Re: NFSv4 behaviour on unknown users
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CF42D78.3010604@shiftmail.org>
Date: Tue, 30 Nov 2010 10:20:48 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <0BB34E2F-8857-40EA-B01A-2F848F3AD1DA@oracle.com>
References: <4CF3E3AD.2040502@shiftmail.org> <20101129195010.GA6423@hostway.ca> <4CF42D78.3010604@shiftmail.org>
To: Spelic <spelic@shiftmail.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 29, 2010, at 5:47 PM, Spelic wrote:

> I'd be glad to go back to NFS version 3 but we need nfs on infiniband rdma now, and afaik it's only available in version 4.

NFS/RDMA is also available for NFSv3, in fact that's where it was first fully implemented.  Whether it is well-supported upstream is another question entirely.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




