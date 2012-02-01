Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:58020 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab2BAUF4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 15:05:56 -0500
Subject: Re: [PATCH 2/2] NFS: add mount option 'v4.1'
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1328126374.3789.111.camel@lade.trondhjem.org>
Date: Wed, 1 Feb 2012 15:05:51 -0500
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <BD18F976-317D-4651-9674-8C564B13E8E3@oracle.com>
References: <1328122817-661-1-git-send-email-dros@netapp.com> <1328122817-661-2-git-send-email-dros@netapp.com> <16B8D5D9-4373-474E-A54A-AF853AC59153@oracle.com> <1328125568.3789.103.camel@lade.trondhjem.org> <58E70AA6-71A7-4C5F-8423-523769D5B2C6@oracle.com> <1328126374.3789.111.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 1, 2012, at 2:59 PM, Myklebust, Trond wrote:

> On Wed, 2012-02-01 at 14:48 -0500, Chuck Lever wrote:
>> On Feb 1, 2012, at 2:46 PM, Myklebust, Trond wrote:
>> 
>>> On Wed, 2012-02-01 at 14:17 -0500, Chuck Lever wrote:
>>>> Hi-
>>>> 
>>>> I think we should co-ordinate with Solaris on this administrative interface.  Can we discuss in Santa Clara?
>>> 
>>> Unless they have a strong argument for why this is a bad idea, I plan on
>>> just adding this to 3.4. There is no point in foot-dragging on this any
>>> more.
>> 
>> No foot dragging.  We just ask at the next convenient opportunity.  I think they want to go with vers=41.
> 
> "4.1" allows for easier visual and automated parsing of major vs minor
> version. In 8 years from now, I'd prefer to see 'vers=4.10' rather than
> 'vers=410'

Fair enough, and I've made similar points to them in the past.  But you should be having this conversation with the Solaris guys, not me.  Can we have this discussion at Connectathon, when all interested parties will be in the room?  That should still be enough time to allow you to submit this change for 3.4.

(And by the way, you will probably need some adjustment to mount.nfs's string parsing logic as well).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




