Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49445 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab1CWP5C convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 11:57:02 -0400
Subject: Re: [PATCH 0/4] RFC: RPC over AF_LOCAL, kernel client-side
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <B08BDAF0-04A9-42ED-ACCE-6291E0F6BF4E@netapp.com>
Date: Wed, 23 Mar 2011 11:56:55 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <B2821425-392E-4212-94FD-75D232CD4B28@oracle.com>
References: <20110322220518.4360.51304.stgit@matisse.1015granger.net> <B08BDAF0-04A9-42ED-ACCE-6291E0F6BF4E@netapp.com>
To: Andy Adamson <andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 23, 2011, at 11:26 AM, Andy Adamson wrote:

> Are you reviving the "RPC Upcall" that I implemented 10 years ago?

This patchset doesn't specifically revive that idea, as its narrow purpose is to replace kernel rpcbind registration over network loopback.

But the work could be a pre-requisite for a generic upcall mechanism over RPC.  An AF_LOCAL transport can be used as a generic upcall mechanism if user space services set up an AF_LOCAL listener.

I'm guessing ten years ago there wasn't built-in standardized support for AF_LOCAL RPC transports in the glibc RPC implementation, which may have impeded the success of such a proposal back then.  libtirpc makes AF_LOCAL a little more practical, as the incremental cost of supporting AF_LOCAL for any user space service is now minimal.

Hopefully it should now be easy to start testing assumptions about the development and prototyping costs and the extensibility of using RPC over AF_LOCAL rather than constructing ad hoc upcall mechanisms for new services.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




