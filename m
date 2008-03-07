From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Fri, 07 Mar 2008 13:29:23 -0500
Message-ID: <47D18983.4080507@redhat.com>
References: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>	 <629ABBF6-C368-44AC-B4B9-471296229325@oracle.com> <f88853200803071011j3a70b0abka9142396d3275b10@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: bc Wong <bcwalrus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757614AbYCGS3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2008 13:29:43 -0500
In-Reply-To: <f88853200803071011j3a70b0abka9142396d3275b10-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bc Wong wrote:
> On Fri, Mar 7, 2008 at 8:16 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>   
>> Hi BC-
>>
>>
>>  On Mar 6, 2008, at 10:08 PM, bc Wong wrote:
>>  > There were 2 things wrong with auth flavour ordering:
>>  > - Mountd used to advertise AUTH_NULL as the first flavour on
>>  >   the list, which means that it prefers AUTH_NULL to anything
>>  >   else (as per RFC 2623 section 2.7).
>>  > - Mount.nfs used to scan the returned list in reverse order,
>>  >   and stopping at the first AUTH_NULL or AUTH_SYS encountered.
>>  >   If a server advertises (AUTH_SYS, AUTH_NULL), it will by
>>  >   default choose AUTH_NULL and have degraded access.
>>
>>  This patch addresses problems only in the legacy part of the user
>>  space mount.nfs command.  Since 2.6.24 NFS mount option parsing is
>>  handled in the kernel instead.
>>
>>  I don't think the new in-kernel mount client even supports receiving
>>  a list of auth flavors from the server.  Do you have an equivalent
>>  patch for that?  If you'd like help we can discuss it off-line.
>>     
>
> Hi Chuck,
>
> Sorry I was totally unaware of the the migration of option parsing
> into the kernel. At first glance, it seems that the client will just
> insist on using whatever is specified in `sec=', even thought the
> server does not advertise it. The server would probably return an
> NFS RPC error, instead of a MOUNT error. I can look into fixing
> the kernel client as well.
>
>   

Actually, NFS servers that support AUTH_NONE, map the uid and gid to the
anonymous uid and gids for access to file systems which are exported
AUTH_NONE.  It doesn't seem to matter what authentication flavor that
the client uses.

       ps

> I'd still like the submitted patch to be considered. It's quite bad
> that mount.nfs would encounter (AUTH_SYS, AUTH_NULL) and
> pick the latter.
>
> Thanks,
> bc
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

