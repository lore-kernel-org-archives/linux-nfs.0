Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:28724 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932575AbaE2QyV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 12:54:21 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: NFSoRDMA developers bi-weekly meeting minutes (5/28)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5387615E.20206@oracle.com>
Date: Thu, 29 May 2014 12:53:53 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Jeff Becker <jeffrey.c.becker@nasa.gov>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>, wendy.cheng@intel.com,
        "Coulter, Susan K" <skc@lanl.gov>,
        Rupert Dance <rsdance@soft-forge.com>,
        Doug Ledford <dledford@redhat.com>,
        Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <CEC2E6A0-AC07-4C70-B318-AA70F273ECBD@oracle.com>
References: <5387615E.20206@oracle.com>
To: Shirley Ma <shirley.ma@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 29, 2014, at 12:33 PM, Shirley Ma <shirley.ma@oracle.com> wrote:

> 2. NFSoRDMA support with soft RoCE and Soft iWARP
> 
> There were some discussions regarding whether removing RPCRDMA_REGISTER support (one of Chuck's patchset) would impact any other components in the stack. So far soft RoCE hasn't been upstreamed yet.There was a broad consensus not to support out-of-tree providers unless an issue also affects in-tree providers. NFSoRDMA will follow kernel development policy, all work should be based upon upstream kernel. However Chuck Level will check Soft RoCE plan, Steve Wise will check soft iWARP plan to make sure nothing will be broken in both kernel and OFED release.

I’ve confirmed OFED 3.12 does not have the soft RoCE provider, and it is also not in mainline. It’s sort of in the same limbo that the NFS/RDMA server-side code is.

I will pursue our technical questions with System Fabrics (authors of rxe).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



