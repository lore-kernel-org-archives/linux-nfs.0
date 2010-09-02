Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30011 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970Ab0IBQmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 12:42:05 -0400
Message-ID: <4C7FD3D1.30601@RedHat.com>
Date: Thu, 02 Sep 2010 12:41:53 -0400
From: Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@redhat.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com> <20100901204818.GA10507@fieldses.org> <20100901165605.41f4978d@tlielax.poochiereds.net> <20100902073156.577757b5@notabene> <4C7F8A80.3050705@RedHat.com> <20100902075518.58a1daf3@corrin.poochiereds.net> <8310F0E2-777C-4F17-B133-766FBAD30E19@oracle.com> <20100902142501.GD13117@fieldses.org>
In-Reply-To: <20100902142501.GD13117@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/02/2010 10:25 AM, J. Bruce Fields wrote:
> On Thu, Sep 02, 2010 at 10:04:19AM -0400, Chuck Lever wrote:
>> Neil's patches are now in upstream nfs-utils.  You can disable all of
>> the network listeners with command line options on mountd.
>>
>> It's been said that people complain that they don't like running
>> rpc.mountd on NFSv4-only servers.  I'm not sure why that's a problem
>> we have to fix with a code change.  Better documentation, better
>> automatic configuration detection in the NFS start-up scripts, or
>> simply renaming rpc.mountd could solve this issue without the need for
>> rip-and-replace of well-tested code.
I think a lot of the problems come from people having to open up 
their firewalls and such... basically security issues..  was well 
as having "extra" daemons stealing cpu cycles... 

> 
> Yeah, I've suggested a separate upcall-handling daemon before, but agree
> that for now we should leave well enough alone.
What would be the deciding factor to start this work? Maybe when
Trond done splitting up kernel code into separate version modules? 

steved.
