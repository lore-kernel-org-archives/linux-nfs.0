Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:46878 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210AbcGMQts convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jul 2016 12:49:48 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 7F6DA280701
	for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 18:49:02 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 724F913E95
	for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 18:49:02 +0200 (MEST)
Date: Wed, 13 Jul 2016 18:49:01 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Andy Adamson <William.Adamson@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <steved@redhat.com>
Message-ID: <1826288060.966410.1468428541658.JavaMail.zimbra@desy.de>
In-Reply-To: <34F13011-FB4A-4ACD-9DDC-BAD3F7EC9B56@netapp.com>
References: <1485779983.22627050.1467888579184.JavaMail.zimbra@desy.de> <34F13011-FB4A-4ACD-9DDC-BAD3F7EC9B56@netapp.com>
Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Andy,

I will try to get upstream kernel on one of the nodes. It will take
some time as we need to add a new host into the cluster and get
some traffic go through it.

In the mean while, with RHEL7 we get it easy reproduced - about 10
such cases per day. Is there any tool that will help us to see where
it happens? Some traces points? Call trace from vfs close to NFS close?


There is a one comment in the kernel code, which sounds similar:
(http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=blob;f=fs/nfs/nfs4proc.c;h=519368b987622ea23bea210929bebfd0c327e14e;hb=refs/heads/linux-next#l2955)

nfs4proc.c: 2954
==== 

/* 
 * It is possible for data to be read/written from a mem-mapped file 
 * after the sys_close call (which hits the vfs layer as a flush).
 * This means that we can't safely call nfsv4 close on a file until 
 * the inode is cleared. This in turn means that we are not good
 * NFSv4 citizens - we do not indicate to the server to update the file's 
 * share state even when we are done with one of the three share 
 * stateid's in the inode.
 *
 * NOTE: Caller must be holding the sp->so_owner semaphore!
 */
int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)

====


Tigran.


----- Original Message -----
> From: "Andy Adamson" <William.Adamson@netapp.com>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>, "Andy Adamson" <William.Adamson@netapp.com>, "Trond Myklebust"
> <trond.myklebust@primarydata.com>, "Steve Dickson" <steved@redhat.com>
> Sent: Tuesday, July 12, 2016 7:16:19 PM
> Subject: Re: Lost CLOSE with NFSv4.1 on RHEL7 ( and bejond?)

> Hi Tigran
> 
> Can you test with an upstream kernel? Olga has seen issues around no CLOSE being
> sent - it is really hard to reproduce….
> 
> —>Andy
> 
> 
>> On Jul 7, 2016, at 6:49 AM, Mkrtchyan, Tigran <tigran.mkrtchyan@desy.de> wrote:
>> 
>> 
>> 
>> Dear NFS folks,
>> 
>> we observe orphan open-states on our deployment with nfsv4.1.
>> Our setup - two client nodes, running RHEL-7.2 with kernel
>> 3.10.0-327.22.2.el7.x86_64. Both nodes running ownCloud (like
>> a dropbox) which nfsv4.1 mounts to dCache storage. Some clients
>> connected to node1, others to node2.
>> 
>> Time-to-time we see some 'active' transfers on data our DS
>> which do nothing. There is a corresponding state on MDS.
>> 
>> I have traced one one such cases:
>> 
>>  - node1 uploads the file.
>>  - node2 reads the file couple of times, OPEN+LAYOUTGET+CLOSE
>>  - node2 sends OPEN+LAYOUTGET
>>  - there is no open file on node2 which points to it.
>>  - CLOSE never send to the server.
>>  - node1 eventually removes the removes the file
>> 
>> We have many other cases where file is not removed, but this one I was
>> able to trace. The link to capture files:
>> 
>> https://desycloud.desy.de/index.php/s/YldowcRzTGJeLbN
>> 
>> We had ~ 10^6 transfers in last 2 days and 29 files in such state (~0.0029%).
>> 
> > Tigran.
