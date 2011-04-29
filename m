Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23102 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759214Ab1D2PiT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2011 11:38:19 -0400
Subject: Re: Linux to Netapp -> Is UDP over WAN safe as long as I use "sync, hard and intr" ?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <D158BE8E-BEDC-43EF-9C6C-48668AA6F5DF@gmail.com>
Date: Fri, 29 Apr 2011 11:38:03 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <20AFBC51-7103-47E9-825A-A52B4FCA08B6@oracle.com>
References: <D158BE8E-BEDC-43EF-9C6C-48668AA6F5DF@gmail.com>
To: David McGiven <davidmcgivenn@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 29, 2011, at 11:07 AM, David McGiven wrote:

> Dear All,
> 
> I'm having problems with Linux NFS clients accessing a NetApp NFS server. The problems are mostly because it's a WAN connection (with 3 hops in between). There's a mixture of poor WAN performance and Ubuntu kernel bugs regarding NFS locks. I've been struggling with this for too long. I then tried UDP instead of TCP and all the problem seem to have vanished :
> 
> I get better performance.
> I don't get lock errors and stalled connections in the kernel.
> I don't get nfs server xxx.xxx.xx not responding any more.
> 
> So I guess I will use UDP, no matter if TCP is recommended in terms of performance. Also, I can't control the WAN routers and switches so I'm tied up to that.
> 
> My concerns are, is it OK to use UDP over WAN regarding data corruption ? I've read that UDP over WAN can cause it, and I'm a little bit afraid, although I don't know why would it corrupt data if it's "sync,hard,intr" as the mount options.

The main source of data corruption in your case would be IP reassembly problems.  The IP ID field is just 16 bits.  If a UDP packet is large, it is spread across many IP packets, and the receiving end can screw up packet reassembly if the ID field wraps.

You can mitigate this risk by capping the size of read and write requests.  Assuming an end-to-end MTU of 1536 octets, using rsize=wsize=1024 would eliminate the possibility of packet mis-assembly on reads and writes.  However, performance might suffer.  A somewhat larger transfer size might perform better, with acceptably small risk of data corruption.

Though I must say, it is quite rare that TCP shows this kind of misbehavior while UDP does not.  I think it would be worth some trouble to root-cause the networking issues here.  It may be as simple as incorrect firewall settings.  Have you looked at packet traces?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




