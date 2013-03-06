Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:50590 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443Ab3CFVUo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 16:20:44 -0500
Date: Wed, 6 Mar 2013 13:20:43 -0800
From: Simon Kirby <sim@hostway.ca>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv3 TCP socket stuck when all slots used and server goes away
Message-ID: <20130306212043.GA7653@hostway.ca>
References: <20130306095138.GC4736@hostway.ca>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1981@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286B1981@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 06, 2013 at 02:06:01PM +0000, Myklebust, Trond wrote:

> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Simon Kirby
> > Sent: Wednesday, March 06, 2013 4:52 AM
> > To: linux-nfs@vger.kernel.org
> > Subject: NFSv3 TCP socket stuck when all slots used and server goes away
> > 
> > We had an issue with an Pacemaker/CRM HA-NFSv3 setup where one
> > particular export hit an XFS locking issue on one node and got completely
> > stuck.
> > Upon failing over, service recovered for all clients that hadn't hit the mount
> > since the issue occurred, but almost all of the usual clients (which also statfs
> > commonly as a monitoring check) sat forever (>20
> > minutes) without reconnecting.
> > 
> > It seems that the clients filled the RPC slots with requests over the TCP
> > socket to the NFS VIP and the server ack'd everything at the TCP layer, but
> > was not able to reply to anything due to the FS locking issue. When we failed
> > over the VIP to the other node, service was restored, but the clients stuck
> > this way continued to sit with nothing to tickle the TCP layer. netstat shows a
> > socket with no send-queue, in ESTABLISHED state, and with no timer
> > enabled:
> > 
> > tcp        0      0 c:724         s:2049       ESTABLISHED -                off (0.00/0/0)
> > 
> > The mountpoint options used are: rw,hard,intr,tcp,vers=3
> > 
> > The export options are:
> > rw,async,hide,no_root_squash,no_subtree_check,mp
> > 
> > Is this expected behaviour? I suspect if TCP keepalived were enabled, the
> > socket would eventually get torn down as soon as the client tries to send
> > something to the (effectively rebooted / swapped) NFS server and gets an
> > RST. However, as-is, there seems to be nothing here that would eventually
> > cause anything to happen. Am I missing something?
> 
> Which client? Did the server close the connection?

Oh. 3.2.16 knfsd server, 3.2.36 - 3.2.39 clients (about 20 of them).

The server did not close the connection but got stonith'd by the other
node (equivalent to a hard reboot of a single node). The socket doesn't
get a FIN or anything, because the server just goes away. When it comes
back, there is nothing on the server to know that the socket ever
existed. With no send-queue and nothing un-acked on the client's view,
and no keepalive timer or anything else, the client never seems to send
anything, so it doesn't ever poke the server and get back an RST to tear
down the socket on the client side, allowing it to reconnect.

I have dmesg saved from an "rpcdebug -m rpc -c" after this occurred, but
I didn't paste it originally because I am wondering if the client _is_
supposed to re-issue requests the RPC TCP socket if no response is
received after this long. With no timeo specified, /proc/mounts shows the
default timeo is 600 seconds, retrans 2. Is it supposed to send something
over the socket again every 600 seconds if all slots were previously used
to issue NFS requests but nothing has been answered?

http://0x.ca/sim/ref/3.2.39/rpcdebug.txt

Cheers,

Simon-
