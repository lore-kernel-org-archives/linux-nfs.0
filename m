Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:56370 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759308AbaD3UAl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 16:00:41 -0400
MIME-Version: 1.0
In-Reply-To: <BBF761A6-2407-4457-92D5-8C2EC736BC9D@oracle.com>
References: <53614C03.80606@oracle.com>
	<CAJZOPZJioYdcbDGsk7278sZS7kD9W1dcGEGtYfsFk=Mm7DW3fQ@mail.gmail.com>
	<BBF761A6-2407-4457-92D5-8C2EC736BC9D@oracle.com>
Date: Wed, 30 Apr 2014 23:00:31 +0300
Message-ID: <CAJZOPZJgp-QdxR+PmwACWOSc4h_167J0iBjfmMrPX8sek600WA@mail.gmail.com>
Subject: Re: NFSoRDMA developers bi-weekly meeting announcement (4/30)
From: Or Gerlitz <or.gerlitz@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
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
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 30, 2014 at 10:47 PM, Chuck Lever <chuck.lever@oracle.com>

> If I understood Yan, he is trying to use NFS/RDMA in guests (kvm?).  We
> are pretty sure that is not working at the moment,

can you provide a short 1-2 liner why/what is broken there? the only
thing which I can think of to be not-supported over mlx4 VFs is the
proprietary FMRs, but AFAIK, the nfs-rdma code doesn't even have a
mode which uses them, right?

> but that is a priority
> to get fixed. Shirley has a lab set up and has been looking into it.
