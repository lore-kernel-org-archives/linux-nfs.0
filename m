From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: mount.nfs: access denied by server
Date: Mon, 24 Aug 2009 12:22:18 -0400
Message-ID: <7938BFD0-B07F-4F16-9098-EF8D013A1B7A@oracle.com>
References: <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org> <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com> <1250889345.5700.11.camel@heimdal.trondhjem.org> <20090821213016.GG23529@fieldses.org> <1250890836.5700.19.camel@heimdal.trondhjem.org> <20090821214720.GH23529@fieldses.org> <1250891463.5700.21.camel@heimdal.trondhjem.org> <20090824161004.GB4985@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-xsfywfwIY+M@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:41019 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbZHXRde (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2009 13:33:34 -0400
In-Reply-To: <20090824161004.GB4985@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 24, 2009, at 12:10 PM, J. Bruce Fields wrote:
> On Fri, Aug 21, 2009 at 05:51:02PM -0400, Trond Myklebust wrote:
>> On Fri, 2009-08-21 at 17:47 -0400, J. Bruce Fields wrote:
>>> On Fri, Aug 21, 2009 at 05:40:36PM -0400, Trond Myklebust wrote:
>>>> On Fri, 2009-08-21 at 17:30 -0400, J. Bruce Fields wrote:
>>>>> 	3c1bb23c037, first in 1.1.3, removes AUTH_NULL from that static
>>>>> 		list.
>>>>
>>>> Does the server support auth_null security? I didn't think it did.
>>>
>>> Just off the top of my head, without looking at the code: I  
>>> believe it
>>> treats auth_null rpc calls exactly as if they were auth_sys calls  
>>> with
>>> uid and gid set to the "anonymous" uid and gid.
>>
>> OK, so that would break too.
>
> I've lost track of the antecedent to "that".

I think what is meant here is:

If the NFS server does support AUTH_NULL, (properly working) clients  
won't use it unless it is listed in the flavor list passed back by MNT.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
