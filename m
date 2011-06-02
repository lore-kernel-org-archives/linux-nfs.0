Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:51301 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933414Ab1FBMxs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2011 08:53:48 -0400
Subject: Re: Bind NFS Services to specific IP address
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <BANLkTimH+UPaKbzDnWE4NAPF=b=f+x5aag@mail.gmail.com>
Date: Thu, 2 Jun 2011 08:53:37 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <A842031D-AB09-4CCC-B338-5CA8AD5534C9@oracle.com>
References: <BANLkTimiv7LXs9Jo7ABA5Mc+0Vn+Q1UEug@mail.gmail.com> <BANLkTimH+UPaKbzDnWE4NAPF=b=f+x5aag@mail.gmail.com>
To: Ranjith Kumar <ranjitbat@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 2, 2011, at 4:01 AM, Ranjith Kumar wrote:

> Hi,
> 
> How you bind the nfs services to specific IP address?

As far as I know, the kernel NFSD does not allow binding to any other address than ADDR_ANY.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




