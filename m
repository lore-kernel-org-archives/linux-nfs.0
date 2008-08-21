From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener
	sockets
Date: Thu, 21 Aug 2008 10:41:17 -0400
Message-ID: <20080821144117.GB22587@fieldses.org>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net> <20080813223953.13068.97829.stgit@manray.1015granger.net> <20080814200554.GI23859@fieldses.org> <74E488BD-DB15-41CD-AD30-A8A5213BC140@oracle.com> <20080814203833.GK23859@fieldses.org> <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com> <20080820193126.GB21226@fieldses.org> <48AD5B85.4020807@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	Frank S Filz <ffilz@us.ibm.com>
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40370 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755864AbYHUOmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2008 10:42:08 -0400
In-Reply-To: <48AD5B85.4020807@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> J. Bruce Fields a =C3=A9crit :
>>>> so suppose I'm a server
>>>> administrator, and want my nfs server to listen for ipv6 connectio=
ns.
>>>> Will there be some switch I'll need to flip?

>> On Thu, Aug 14, 2008 at 04:45:31PM -0400, Chuck Lever wrote:
>>> I don't know how that UI will be designed.  So far, I've focused on=
ly=20
>>> on the pieces needed for client side IPv6 support.  I figured the=20
>>> Bull team had something figured out for the server, and didn't thin=
k=20
>>> any more about it.
>>
>> I've forgotten who was working on that; Aurelien Charbon?

On Thu, Aug 21, 2008 at 02:11:49PM +0200, Le Rouzic wrote:
> Sorry for not answering before, I am back from vacation.  Aurelien is
> no longer directly working on that even he can answer any  questions.
> It is me now who tess NFSV4 IPV6 with the patches Aurelien delivered
> to Bruce a few months ago.  But since Chuck has delivered several new
> patches which affect the NFS server side about the way nfsd can liste=
n
> for ipv6 connections.

I merged the last patch I can remember from Aurelien (f15364bd "IPv6
support for NFS server export caches").  Are there some others floating
around that I should look at?

>  To have NFSV4 IPV6 working with those changes, what it would be nice
>  to have a complete list on what are the changes.  Is there now a
>  complete release for which we can test those latest  changes? If not
>  which one will be?  Are there any other changes still planned?

I was hoping you or Chuck would know; I don't know of anyone else
working on nfs over ipv6.

--b.
