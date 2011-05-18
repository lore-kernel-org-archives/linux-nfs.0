Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:16657 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab1ERUL1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2011 16:11:27 -0400
Subject: Re: NFS: pnfs ipv6 and multipath parsing
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1305748634-28348-1-git-send-email-dros@netapp.com>
Date: Wed, 18 May 2011 16:11:15 -0400
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <AA6F9C64-8FDB-4B0A-B8CB-80AB4FA3D985@oracle.com>
References: <1305748634-28348-1-git-send-email-dros@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 18, 2011, at 3:57 PM, Weston Andros Adamson wrote:

> These two patches add support for IPv6 dataserver connectivity and 
> parsing all multipath addresses.
> 
> IPv6: basically same patch as before:
> - no longer calls kzalloc() while holding spinlock
> - i verified that everything works as expected when CONFIG_IPV6 is not defined

You'll also need to worry about when IPv6 is built in a kernel module, but ipv6.ko cannot be loaded.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




