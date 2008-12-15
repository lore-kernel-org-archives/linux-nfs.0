From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Mon, 15 Dec 2008 12:26:41 -0500
Message-ID: <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com>
References: <49468BC7.2000907@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:42937 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbYLOR1O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:27:14 -0500
In-Reply-To: <49468BC7.2000907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 15, 2008, at 11:54 AM, Steve Dickson wrote:
> Recently I was asked to re-enable the TCP wrapper calls, that check  
> the
> validity of client that communicate with mountd and statd.
>
> It became very apparent this code had not been used in a while
> and was as a bit broken. So this patch set fixes the logic and
> tries to make the code scale better.
>
> The commit blobs in the set are relative to the 'tcpwrap'
> branch in the git://linux-nfs.org/~steved/nfs-utils-exp.git
> git tree.
>
> Comments?

A general comment:  This code will need support for IPv6 addresses.

Until it has it, perhaps we should add some logic to configure.ac that  
prevents the use of tcpwrappers when --enable-ipv6 is in effect.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
