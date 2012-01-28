Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41869 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985Ab2A1QwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jan 2012 11:52:11 -0500
Received: by vcbgb30 with SMTP id gb30so1857689vcb.19
        for <linux-nfs@vger.kernel.org>; Sat, 28 Jan 2012 08:52:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F201D30.8010606@panasas.com>
References: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com>
	<20120125143449.GB17873@fieldses.org>
	<4F201D30.8010606@panasas.com>
Date: Sat, 28 Jan 2012 17:52:10 +0100
Message-ID: <CAG+vHKJ2SLE+ertiPHLU48TP-xxQdyx+VJ3nS-oT70EYYPp7Aw@mail.gmail.com>
Subject: Re: NFSv4 - Linux server, FreeBSD client
From: "J. von Balzac" <jhm.balzac@gmail.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

It's not like we've known each other for very long hehe but i am
deleting this Google account, screw them and screw their privacy
issues.

So just FYI. I'll report back with some other account.

On 25 January 2012 16:18, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 01/25/2012 04:34 PM, J. Bruce Fields wrote:
>> Also, "fsid=0" tricks aren't necessary any more: if you just leave out
>> that line, then v4 clients will be able to mount /exp/freebsd/* just as
>> v2/v3 clients would.
>>
>
> I suspected this, but have been using fsid=0 since forever and the :/ mounts.
> I'll check it out
>
> I know it's not your expertise, but is it also true for pnfs. (Benny's tree)
> Or like before pnfs export must have the fsid=0 set?
>
> What about multiple SBs / FSs exporting pnfs should that work? I guess I should
> try it.
>
> Thanks
> Boaz
