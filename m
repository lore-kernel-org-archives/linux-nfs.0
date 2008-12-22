Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:45063 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbYLVRXL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Dec 2008 12:23:11 -0500
Date: Mon, 22 Dec 2008 12:23:09 -0500
To: James Pearson <james-p@moving-picture.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with Mac clients mounting a Linux server behind a
	firewall
Message-ID: <20081222172309.GO4191@fieldses.org>
References: <a92ebfd90812191452l4b10362av5e9c8876335c32bc@mail.gmail.com> <494FC625.4040207@moving-picture.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <494FC625.4040207@moving-picture.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 22, 2008 at 04:53:57PM +0000, James Pearson wrote:
> James Pearson wrote:
>> I'm not absolutely sure if this is an NFS server issue, but I have an
>> Linux NFS server running CentOS4 that sits behind a firewall - about
>> once a week rpciod ends up using 99% CPU and the machine needs to be
>> rebooted
>>
>> When it gets into this state, running 'netstat -u -a' shows thousands
>> of entries like:
>>
>> udp        0      0 *:35071                     *:*
>> udp        0      0 *:34815                     *:*
>> udp        0      0 *:34559                     *:*
>> udp        0      0 *:34303                     *:*
>> udp        0      0 *:34047                     *:*
>> udp        0      0 *:33791                     *:*
>> udp        0      0 *:33535                     *:*
>> udp        0      0 *:33279                     *:*
>> udp        0      0 *:33151                     *:*
>> udp        0      0 *:32895                     *:*
>>
>> and tcpdump shows lots of udp connection attempts to port 111 on
>> various Macs that are or have mounted the server (via an automounter).
>> The connections don't get through as they are blocked by the firewall.
>> None of these blocked connections are to Linux clients - it's just Mac
>> clients
>>
>> Is there anything that NFS server-wise that could be cause the server
>> to attempt to contact clients in this way?
>
> Running wireshark over the tcpdump output, all these portmap calls are like:
>
> User Datagram Protocol, Src Port: 51947 (51947), Dst Port: sunrpc (111)
> Remote Procedure Call, Type:Call XID:0xacd4150f
> Portmap GETPORT Call NLM(100021) Version:4 UDP
>     [Program Version: 2]
>     [V2 Procedure: GETPORT (3)]
>     Program: NLM (100021)
>     Version: 4
>     Proto: UDP (17)
>     Port: 0
>
> Why would an NFS server need to initiate a call to the lockd process on  
> a (MacOS) client?

The communication between lockd's is 2-way, so that, for example,
servers can notify clients when locks are available.  Also, the server's
statd needs to contact the clients so it can ask the clients to notify
it when the clients reboot (and hence when their file locks should be
released).  And similarly the server needs to be able to notify the
clients when it reboots, so the client can reclaim any locks it
previously held.

So your firewall settings are a problem.  But, obviously, we should be
handling this more gracefully on the server.

--b.
