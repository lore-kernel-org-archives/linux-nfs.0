Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:44315 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756816Ab3CFOGD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 09:06:03 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simon Kirby <sim@hostway.ca>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: NFSv3 TCP socket stuck when all slots used and server goes away
Date: Wed, 6 Mar 2013 14:06:01 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1981@sacexcmbx05-prd.hq.netapp.com>
References: <20130306095138.GC4736@hostway.ca>
In-Reply-To: <20130306095138.GC4736@hostway.ca>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Simon Kirby
> Sent: Wednesday, March 06, 2013 4:52 AM
> To: linux-nfs@vger.kernel.org
> Subject: NFSv3 TCP socket stuck when all slots used and server goes away
> 
> We had an issue with an Pacemaker/CRM HA-NFSv3 setup where one
> particular export hit an XFS locking issue on one node and got completely
> stuck.
> Upon failing over, service recovered for all clients that hadn't hit the mount
> since the issue occurred, but almost all of the usual clients (which also statfs
> commonly as a monitoring check) sat forever (>20
> minutes) without reconnecting.
> 
> It seems that the clients filled the RPC slots with requests over the TCP
> socket to the NFS VIP and the server ack'd everything at the TCP layer, but
> was not able to reply to anything due to the FS locking issue. When we failed
> over the VIP to the other node, service was restored, but the clients stuck
> this way continued to sit with nothing to tickle the TCP layer. netstat shows a
> socket with no send-queue, in ESTABLISHED state, and with no timer
> enabled:
> 
> tcp        0      0 c:724         s:2049       ESTABLISHED -                off (0.00/0/0)
> 
> The mountpoint options used are: rw,hard,intr,tcp,vers=3
> 
> The export options are:
> rw,async,hide,no_root_squash,no_subtree_check,mp
> 
> Is this expected behaviour? I suspect if TCP keepalived were enabled, the
> socket would eventually get torn down as soon as the client tries to send
> something to the (effectively rebooted / swapped) NFS server and gets an
> RST. However, as-is, there seems to be nothing here that would eventually
> cause anything to happen. Am I missing something?

Which client? Did the server close the connection?

Cheers
  Trond
