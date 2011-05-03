Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:28315 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801Ab1ECUGK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 16:06:10 -0400
Subject: Re: [RFC 0/1] SUNRPC: dynamic rpc_slot allocator for TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1304386808-2733-1-git-send-email-andros@netapp.com>
Date: Tue, 3 May 2011 16:06:00 -0400
Cc: trond.myklebust@netapp.com, jlayton@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <0C6F7F78-D506-463B-B4B7-D780BA9FA95F@oracle.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
To: andros@netapp.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

On May 2, 2011, at 9:40 PM, andros@netapp.com wrote:

> I would appreciate comments on this patch. I've done a small amount of testing
> where I've set the /proc/sys/sunrpc/tcp_slot_table_entries to 2, and watched
> the dynamic allocator increase it to 3. I have a 10G test system being
> configured.

For TCP transports, then, the effective slot table size varies between the tcp_slot_table_entries setting and the estimated number of RPCs that can fit in the TCP window?  What happens when the TCP window shrinks such that fewer RPCs can fit than are allowed by the tcp_slot_table_entries setting?

Have you done performance testing with loopback mounts (ie server and client on the same machine, mounting over the "lo" interface)?  As I recall this was the test case that Trond found worked poorly when we boosted the tcp_slot_table_entries setting to default to a 64 entry slot table.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




