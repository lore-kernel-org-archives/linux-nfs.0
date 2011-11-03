Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:46800 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536Ab1KCPAU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 11:00:20 -0400
Subject: Re: rpcbind listen on localhost only?
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111103025154.GA10875@umich.edu>
Date: Thu, 3 Nov 2011 11:00:07 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <50A0FDE4-6E60-410A-98BD-0BA3F32D5DE9@oracle.com>
References: <20111103025154.GA10875@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 2, 2011, at 10:51 PM, Jim Rees wrote:

> How do I get rpcbind to only listen on localhost and not on INADDR_ANY,
> equivalent to the "-l" option to portmap?  The man page implies that
> "-h 127.0.0.1" should do it, but that doesn't work.

I imagine this doesn't work because for localhost, rpcbind listens on AF_LOCAL socket /var/run/rpcbind.sock.  This allows authentication of the registrand.  Normally this interface isn't exposed directly to applications: they use the APIs in libtirpc (or glibc) to access the local rpcbind service.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




