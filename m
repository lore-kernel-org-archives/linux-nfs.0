From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Fri, 07 Mar 2008 14:10:46 -0500
Message-ID: <47D19336.9010903@redhat.com>
References: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>	 <629ABBF6-C368-44AC-B4B9-471296229325@oracle.com>	 <f88853200803071011j3a70b0abka9142396d3275b10@mail.gmail.com>	 <47D18983.4080507@redhat.com> <f88853200803071059yf523114wcabb12fdeee7b8d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: bc Wong <bcwalrus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49226 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948AbYCGTLG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2008 14:11:06 -0500
In-Reply-To: <f88853200803071059yf523114wcabb12fdeee7b8d6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bc Wong wrote:
> On Fri, Mar 7, 2008 at 10:29 AM, Peter Staubach <staubach@redhat.com> wrote:
>   
>>  Actually, NFS servers that support AUTH_NONE, map the uid and gid to the
>>  anonymous uid and gids for access to file systems which are exported
>>  AUTH_NONE.  It doesn't seem to matter what authentication flavor that
>>  the client uses.
>>
>>        ps
>>     
>
> Hi Peter,
>
> My concern is that a server supports both AUTH_SYS and AUTH_NONE,
> where AUTH_SYS would give you the regular access, and AUTH_NONE
> would give the anon access as you described, which is typically a
> degraded read-only view. Therefore it's bad for the client to choose
> AUTH_NONE in this case, especially since the server presents
> AUTH_SYS *before* AUTH_NONE.
>
> I'll test more with AUTH_NONE on Solaris. Is there any specific setup
> you'd like me to verify?

Do you know of any client NFS implementations that can actually generate
requests with AUTH_NONE as the authentication flavor?  Which server
implementation supports the mode that you described?

As far as I know, all servers, which support exporting with AUTH_NONE,
always map the incoming uid and gid(s) to the anonymous uid and gid when
they process the request for a file system which is exported with AUTH_NONE.
It doesn't seem to matter what the incoming authentication flavor was.

    Thanx...

       ps
