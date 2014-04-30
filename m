Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:17253 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186AbaD3TsY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:48:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: NFSoRDMA developers bi-weekly meeting announcement (4/30)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAJZOPZJioYdcbDGsk7278sZS7kD9W1dcGEGtYfsFk=Mm7DW3fQ@mail.gmail.com>
Date: Wed, 30 Apr 2014 15:47:57 -0400
Cc: Shirley Ma <shirley.ma@oracle.com>,
        Jeff Becker <jeffrey.c.becker@nasa.gov>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>,
        "Cayton, Phil" <phil.cayton@intel.com>,
        "Coulter, Susan K" <skc@lanl.gov>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "<Devesh.Sharma@emulex.com>" <Devesh.Sharma@emulex.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Allen Andrews <Allen.Andrews@emulex.com>,
        Jeff Layton <jlayton@redhat.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "<emossman@iol.unh.edu>" <emossman@iol.unh.edu>
Message-Id: <BBF761A6-2407-4457-92D5-8C2EC736BC9D@oracle.com>
References: <53614C03.80606@oracle.com> <CAJZOPZJioYdcbDGsk7278sZS7kD9W1dcGEGtYfsFk=Mm7DW3fQ@mail.gmail.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Or-

On Apr 30, 2014, at 3:39 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:

> On Wed, Apr 30, 2014 at 10:16 PM, Shirley Ma <shirley.ma@oracle.com> wrote:
> [...]
>> 3. Upstream NFSoRDMA status:
> 
> 
> So does it currently works...? I understand that Yan tried it out
> today, and @ least one side just crashed.
> 
> Chuck, I assume there is a configuration which basically works for you
> and allow you to develop the upstream patches, you send, right?  can
> you send us your .config and exact NFS/rNFS options you use and works
> basically OK?

If I understood Yan, he is trying to use NFS/RDMA in guests (kvm?).  We
are pretty sure that is not working at the moment, but that is a priority
to get fixed. Shirley has a lab set up and has been looking into it.

So, first step would be to set up v3.15-rc3 on bare metal.

I think the critical stability patches for both client and server are
already upstream, unless you are exporting tmpfs.

The patches I just posted fix some other issues, feel free to apply them.
But the basics should be working now in v3.15-rc3.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



