From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: root over nfs, error -93
Date: Wed, 28 May 2008 18:23:40 -0400
Message-ID: <483DDB6C.4040209@oracle.com>
References: <1212009456.3786.24.camel@wf>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060603090609010000010700"
Cc: linux-nfs@vger.kernel.org
To: Julius <julius.junghans@gmx.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50915 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401AbYE1WYE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2008 18:24:04 -0400
In-Reply-To: <1212009456.3786.24.camel@wf>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060603090609010000010700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Julius wrote:
> Hi,
> 
> 
> im trying to get a client boot from my server via nfs. but it fails
> with:
> 
> Root-NFS: Server returned error -93 while
> mounting /nfs-exports/pxeclient

Error 93 is EPROTONOSUPPORT.  Is there a firewall between client and 
server?  tcpwrappers on either end?  Are you using a motherboard NIC 
that silently hijacks a reserved UDP port?

Try capturing a network trace with "tcpdump -s0 -w /tmp/dump" on your 
server while your client boots.  Take a look at it with wireshark or 
tethereal.

> the client uses a vanilla 2.6.24.7 kernel with these settings:
> <*>   NFS file system support 
>  [*]     Provide NFSv3 client support 
>  [*]       Provide client support for the NFSv3 ACL protocol extension 
>  [*]   Root file system on NFS
>  [*]   Support for rpcbind versions 3 & 4 (EXPERIMENTAL)
> 
> 
> full config:
> http://metalfan2.me.funpic.de/.config
> 
> 
> kernel append line:
> append root=/dev/nfs nfsroot=192.168.11.3:/nfs-exports/pxeclient ip=dhcp
> 
> 
> the system successfully boots the kernel via syslinux and requests its
> ip via dhcp
> 
> 
> server:
> rpcinfo -p localhost
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  54039  status
>     100024    1   tcp  57693  status
>     100005    3   udp  48497  mountd
>     100005    3   tcp  34406  mountd
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100021    1   udp  47061  nlockmgr
>     100021    3   udp  47061  nlockmgr
>     100021    4   udp  47061  nlockmgr
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   tcp  54896  nlockmgr
>     100021    3   tcp  54896  nlockmgr
>     100021    4   tcp  54896  nlockmgr
> 
> nfs-utils-1.1.0
> 
> 
> 
> Any ideas whats wrong?
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--------------060603090609010000010700
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060603090609010000010700--
