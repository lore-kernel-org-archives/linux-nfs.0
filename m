Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757250Ab0HaMZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Aug 2010 08:25:07 -0400
Message-ID: <4C7CF499.5090003@RedHat.com>
Date: Tue, 31 Aug 2010 08:24:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>	<4C7BD394.3030705@RedHat.com>	<20100830121600.529669bd@tlielax.poochiereds.net>	<4C7BE1FC.2020400@RedHat.com> <20100830134801.1696dffa@tlielax.poochiereds.net>
In-Reply-To: <20100830134801.1696dffa@tlielax.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/30/2010 01:48 PM, Jeff Layton wrote:
> On Mon, 30 Aug 2010 12:53:16 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>> Hmmm...if I had known that it was ok to stop supporting old kernels,
>>> the IPv6 support for rpc.nfsd would have been a heck of a lot easier to
>>> implement.
>> I thought you said the legacy interface would not work with IPV6 or
>> did I misunderstand you? 
>>
> 
> Sorry, forgot to answer this part. IPv6 indeed will not work when using
> the legacy interface. In order to get the IPv6 code in though, I ended
> up rewriting a large swath of rpc.nfsd. That task would have been
> easier had I not needed to deal with the legacy nfsctl() interface.
> 
So I'm thinking this the final nail in the coffin of the legacy interface
at least in rpc.nfsd. So if /proc/fs/nfsd filesystem is not or can not
be mounted then rpc.nfsd should fail... IMHO...

Maybe something like:

if (stat("/proc/fs/nfsd") < 0) {
    if (system("mount /proc/fs/nfsd") < 0) {
        xlog(L_ERROR, "Unable to mount /proc/fs/nfsd");
        exit 0;
    }
}

steved.
