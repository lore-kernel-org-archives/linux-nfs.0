Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:34480 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753419AbYLVRQB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Dec 2008 12:16:01 -0500
Received: from cassini.mpc.local ([172.16.15.37] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43)
	id 1LEo2X-0000ND-Sc
	for linux-nfs@vger.kernel.org; Mon, 22 Dec 2008 16:53:57 +0000
Message-ID: <494FC625.4040207@moving-picture.com>
Date: Mon, 22 Dec 2008 16:53:57 +0000
From: James Pearson <james-p@moving-picture.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Problems with Mac clients mounting a Linux server behind a firewall
References: <a92ebfd90812191452l4b10362av5e9c8876335c32bc@mail.gmail.com>
In-Reply-To: <a92ebfd90812191452l4b10362av5e9c8876335c32bc@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

James Pearson wrote:
> I'm not absolutely sure if this is an NFS server issue, but I have an
> Linux NFS server running CentOS4 that sits behind a firewall - about
> once a week rpciod ends up using 99% CPU and the machine needs to be
> rebooted
> 
> When it gets into this state, running 'netstat -u -a' shows thousands
> of entries like:
> 
> udp        0      0 *:35071                     *:*
> udp        0      0 *:34815                     *:*
> udp        0      0 *:34559                     *:*
> udp        0      0 *:34303                     *:*
> udp        0      0 *:34047                     *:*
> udp        0      0 *:33791                     *:*
> udp        0      0 *:33535                     *:*
> udp        0      0 *:33279                     *:*
> udp        0      0 *:33151                     *:*
> udp        0      0 *:32895                     *:*
> 
> and tcpdump shows lots of udp connection attempts to port 111 on
> various Macs that are or have mounted the server (via an automounter).
> The connections don't get through as they are blocked by the firewall.
> None of these blocked connections are to Linux clients - it's just Mac
> clients
> 
> Is there anything that NFS server-wise that could be cause the server
> to attempt to contact clients in this way?

Running wireshark over the tcpdump output, all these portmap calls are like:

User Datagram Protocol, Src Port: 51947 (51947), Dst Port: sunrpc (111)
Remote Procedure Call, Type:Call XID:0xacd4150f
Portmap GETPORT Call NLM(100021) Version:4 UDP
     [Program Version: 2]
     [V2 Procedure: GETPORT (3)]
     Program: NLM (100021)
     Version: 4
     Proto: UDP (17)
     Port: 0

Why would an NFS server need to initiate a call to the lockd process on 
a (MacOS) client?

Thanks

James Pearson
