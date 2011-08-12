Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:54867 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab1HLUoc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 16:44:32 -0400
Message-ID: <4E4590A4.1080803@panasas.com>
Date: Fri, 12 Aug 2011 13:44:20 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com> <4E4481F0.2050806@panasas.com> <20110812021556.GD9761@pad.fieldses.org> <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com> <20110812143228.GD16960@pad.fieldses.org> <4E456BBB.1030605@panasas.com> <20110812183945.GJ16960@pad.fieldses.org> <4E45785D.40103@panasas.com> <20110812203606.GL16960@pad.fieldses.org>
In-Reply-To: <20110812203606.GL16960@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 01:36 PM, J. Bruce Fields wrote:
> On Fri, Aug 12, 2011 at 12:00:45PM -0700, Boaz Harrosh wrote:
> 
> Is this actually the deleg reclaim case that Trond mentioned?  Could I
> see a trace?
> 

No it's the:
	NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS

problem that you sent a fix for. See my other mail

> --b.

Thanks
Boaz
