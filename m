Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:47683 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab2E1Lou (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 07:44:50 -0400
Message-ID: <4FC364F9.4090308@panasas.com>
Date: Mon, 28 May 2012 14:43:53 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, <tao.peng@emc.com>,
        <skinsbursky@parallels.com>, <linux-nfs@vger.kernel.org>,
        <xemul@parallels.com>, <neilb@suse.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <jbottomley@parallels.com>,
        <davem@davemloft.net>, <devel@openvz.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH 4/5] NFS: remove RPC PipeFS mount point reference from
 blocklayout routines
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6> <20111129091037.20730.59391.stgit@localhost6.localdomain6> <F19688880B763E40B28B2B462677FBF805E3A4AFF2@MX09A.corp.emc.com> <4ED4CDCE.9080804@parallels.com> <F19688880B763E40B28B2B462677FBF805E3A4AFFD@MX09A.corp.emc.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC23@SACMVEXC2-PRD.hq.netapp.com> <CA+a=Yy5GKMu8rbh8y3fOtK6pmqygPNBr=a+p7LfcmTqtXFH3iA@mail.gmail.com> <1322579906.3619.1.camel@lade.trondhjem.org> <CA+a=Yy6kJe0NemSiRwM+t8gz5-UF5fOdwdS2so+q=nSYjBx--w@mail.gmail.com> <1322584830.4174.16.camel@lade.trondhjem.org> <20111129164252.GA19528@fieldses.org> <1322587165.4174.20.camel@lade.trondhjem.org> <CA+a=Yy4bEKaeUihjYLRzXVbjA3fc2EuZ3ToAkf0w-oL3PnZJKQ@mail.gmail.com>
In-Reply-To: <CA+a=Yy4bEKaeUihjYLRzXVbjA3fc2EuZ3ToAkf0w-oL3PnZJKQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 07:30 PM, Peng Tao wrote:

> On Wed, Nov 30, 2011 at 1:19 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
>> On Tue, 2011-11-29 at 11:42 -0500, J. Bruce Fields wrote:
>>> On Tue, Nov 29, 2011 at 11:40:30AM -0500, Trond Myklebust wrote:
>>>> I mean that I'm perfectly entitled to do
>>>>
>>>> 'modprobe -r blocklayoutdriver'
>>>>
>>>> and when I do that, then I expect blkmapd to close the rpc pipe and wait
>>>> for a new one to be created just like rpc.idmapd and rpc.gssd do when I
>>>> remove the nfs and sunrpc modules.
>>>
>>> The rpc pipefs mount doesn't hold a reference on the sunrpc module?
>>
>> I stand corrected: the mount does hold a reference to the sunrpc
>> module.
>> However nothing holds a reference to the blocklayoutdriver module, so
>> the main point that the "blocklayout" pipe can disappear from underneath
>> the blkmapd stands.
> Thanks for the explanation and I agree it can cause problem if user
> reload blocklayout module. I will look into a fix to blkmapd.
> 


You might want to consider converting to call_usermodehelper()

I know that it greatly simplified our code both in Kernel and
in user-mode. And it made nfs-utils maintainer much happier
as well.

The speed is not Cardinal here I think. Like in objects it's
done once per new device_id

> Best,
> Tao


Just my $0.017
Boaz
