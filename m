Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:34777 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755222Ab2DWViS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 17:38:18 -0400
Subject: Re: [PATCH 1/3] NFSv4: Ensure we do not reuse open owner names
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1335216748.11427.38.camel@lade.trondhjem.org>
Date: Mon, 23 Apr 2012 17:38:12 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <2D111BD9-B02C-4B58-B5F0-667EF39138F9@oracle.com>
References: <1335213414-20826-1-git-send-email-Trond.Myklebust@netapp.com> <418AC7C0-6289-40D0-85DB-092C29BA40D3@oracle.com> <1335214124.11427.23.camel@lade.trondhjem.org> <537D97FE-BB59-4541-A705-C01178025C48@oracle.com> <1335216748.11427.38.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 23, 2012, at 5:32 PM, Myklebust, Trond wrote:

> On Mon, 2012-04-23 at 16:57 -0400, Chuck Lever wrote:
>> On Apr 23, 2012, at 4:48 PM, Myklebust, Trond wrote:
>> 
>>> On Mon, 2012-04-23 at 16:44 -0400, Chuck Lever wrote:
>>>> Hi-
>>>> 
>>>> I wish you had told me you were going to fix this too.  I've been testing a fix for this for a couple weeks.  Was going to post this afternoon.  Shall I toss mine?
>>> 
>>> I was hitting that BAD_SEQID storm during testing of the other open
>>> fixes last week.
>> 
>> Fair enough, but I announced I had a fix in my April 15 status report.  Oh well.
>> 
>> So, I decided that a timestamp would leak information about the client, so I'm using a simple counter instead.  Would you consider that for your patch?
> 
> How would a timestamp leak useful information? The server and anyone
> monitoring the NFS traffic already knows at what time the open owner was
> created to within a few milliseconds.

It leaks the exact time as the client sees it.  This is why time-based UUIDs are no longer considered safe.

But also, is it possible that a state_owner could be destroyed and created so quickly on a system with inadequate timestamp resolution, such that the new owner ID would not actually be different than the previous one?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




