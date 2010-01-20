From: jin zhencheng <zhenchengjin@gmail.com>
Subject: nfs-error-RPC: multiple fragments per record not supported
Date: Wed, 20 Jan 2010 19:20:34 +0800
Message-ID: <de04351e1001200320y2e763680gc7e3b20319c6386e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	zhenchengjin-9Onoh4P/yGk@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f190.google.com ([209.85.222.190]:64657 "EHLO
	mail-pz0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab0ATLUe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 06:20:34 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I use kernel 2.6.26.2

I use  29 clients,

every client mount parameters as this: mount -t nfs -o
rw,noatime,v3,rsize=32768,wsize=32768,hard,intr,tcp,nolock

my system have many errors lke these :

RPC: multiple fragments per record not supported
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x318c87ee
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x78bdeedb
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x75cf8a33
RPC: fragment too large: 0x44764ada
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x0a08e7c0
RPC: multiple fragments per record not supported
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x5b4e13a1
RPC: fragment too large: 0x08351a9f




cat /var/lib/nfs/rmtab
52.2.1.1:/share/vd01/share01:0x00000088
52.2.1.3:/share/vd01/share01:0x00000085
52.2.1.4:/share/vd01/share01:0x0000005c
52.2.1.6:/share/vd01/share01:0x00000052
52.2.1.7:/share/vd01/share01:0x0000005a
52.2.1.9:/share/vd01/share01:0x0000004e
52.2.1.10:/share/vd01/share01:0x0000008b
52.2.1.11:/share/vd01/share01:0x00000071
52.2.1.12:/share/vd01/share01:0x0000007b
52.2.1.13:/share/vd01/share01:0x0000005d
52.2.1.14:/share/vd01/share01:0x0000007c
52.2.1.15:/share/vd01/share01:0x0000004e
52.2.1.17:/share/vd02/share02:0x00000068
52.2.1.18:/share/vd02/share02:0x00000052
52.2.1.19:/share/vd02/share02:0x00000088
52.2.1.41:/share/vd02/share02:0x00000066
52.2.1.42:/share/vd02/share02:0x0000005f
52.2.1.43:/share/vd02/share02:0x00000075
52.2.1.44:/share/vd02/share02:0x0000008c
52.2.1.45:/share/vd02/share02:0x0000009b
52.2.1.46:/share/vd02/share02:0x00000038
52.2.1.47:/share/vd02/share02:0x000000a0
52.2.1.81:/share/vd02/share02:0x00000014
52.2.1.21:/share/vd02/share02:0x00000062
52.2.1.22:/share/vd02/share02:0x00000077
52.2.1.23:/share/vd02/share02:0x0000007b
52.2.1.2:/share/vd01/share01:0x0000005f
52.2.1.20:/share/vd02/share02:0x0000009f
52.2.0.201:/share/vd02/share02:0x00000002
