From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 17 Oct 2002 09:10:27 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <001301c275e6$f31d5970$2a060e09@beavis>
References: <012d01c27581$677d2180$2a060e09@beavis><20021017.113126.102592502.taka@valinux.co.jp><003301c275e1$0bf76810$2a060e09@beavis> <20021017.222602.48536782.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <neilb@cse.unsw.edu.au>, <davem@redhat.com>,
	<linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Hirokazu Takahashi" <taka@valinux.co.jp>
List-ID: <nfs.lists.sourceforge.net>

> Hi,
>
> > server: Udp: InDatagrams NoPorts InErrors OutDatagrams
> >         Udp: 1000665 41 0 1000666
> > clients: Udp: InDatagrams NoPorts InErrors OutDatagrams
> >          Udp: 200403 0 0 200406
> >          (all clients the same)
>
> How about IP datagrams?  You can see the IP fields in /proc/net/snmp
> IP layer may also discard them.

Server:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams
InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes
ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 1 64 4088714 0 0 720 0 0 4086393 12233109 2 0 0 0 0 0 0 0 6000000

A Client:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams
InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes
ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 2 64 2115252 0 0 0 0 0 1115244 646510 0 0 0 1200000 200008 0 0 0 0


Andrew Theurer
