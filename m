Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23474 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbcBJP2g convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Feb 2016 10:28:36 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: Kernel crash in Centos 6.6
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1455106042.4536.21.camel@fis.unical.it>
Date: Wed, 10 Feb 2016 10:28:28 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BFCA133A-62D0-4304-983B-3183A2528ED3@oracle.com>
References: <1455106042.4536.21.camel@fis.unical.it>
To: fedele.stabile@fis.unical.it
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fedele-

> On Feb 10, 2016, at 7:07 AM, Fedele Stabile <fedele.stabile@fis.unical.it> wrote:
> 
> Hello all,
> I have a kernel crash when I mount an NFS volume using RDMA transport.
> On client and server is installed Centos 6.6 kernel 2.6.32
> -504.8.1.el6.x86_64
> I use nfs v4
> The client hangs if I execute 
> mount -t nfs -o rdma ib-server:/data /data
> Server and client are connected throw Infiniband network and Qlogic
> adapters.

I assume you mean that the mount command hangs, not that
the whole client deadlocks.

Add "port=20049" to the mount options.


--
Chuck Lever




