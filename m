From: "bc Wong" <bcwalrus@gmail.com>
Subject: Re: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Fri, 7 Mar 2008 11:38:57 -0800
Message-ID: <f88853200803071138n58d16ca6t4f4410d587141141@mail.gmail.com>
References: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>
	 <629ABBF6-C368-44AC-B4B9-471296229325@oracle.com>
	 <f88853200803071011j3a70b0abka9142396d3275b10@mail.gmail.com>
	 <47D18983.4080507@redhat.com>
	 <f88853200803071059yf523114wcabb12fdeee7b8d6@mail.gmail.com>
	 <47D19336.9010903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Chuck Lever" <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:58879 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565AbYCGTi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2008 14:38:58 -0500
Received: by wa-out-1112.google.com with SMTP id v27so733018wah.23
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2008 11:38:58 -0800 (PST)
In-Reply-To: <47D19336.9010903@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 7, 2008 at 11:10 AM, Peter Staubach <staubach@redhat.com> wrote:
>
> bc Wong wrote:
>  > On Fri, Mar 7, 2008 at 10:29 AM, Peter Staubach <staubach@redhat.com> wrote:
>  >
>  >>  Actually, NFS servers that support AUTH_NONE, map the uid and gid to the
>  >>  anonymous uid and gids for access to file systems which are exported
>  >>  AUTH_NONE.  It doesn't seem to matter what authentication flavor that
>  >>  the client uses.
>  >>
>  >>        ps
>  >>
>  >
>  > Hi Peter,
>  >
>  > My concern is that a server supports both AUTH_SYS and AUTH_NONE,
>  > where AUTH_SYS would give you the regular access, and AUTH_NONE
>  > would give the anon access as you described, which is typically a
>  > degraded read-only view. Therefore it's bad for the client to choose
>  > AUTH_NONE in this case, especially since the server presents
>  > AUTH_SYS *before* AUTH_NONE.
>  >
>  > I'll test more with AUTH_NONE on Solaris. Is there any specific setup
>  > you'd like me to verify?
>
>  Do you know of any client NFS implementations that can actually generate
>  requests with AUTH_NONE as the authentication flavor?  Which server
>  implementation supports the mode that you described?

Hi Peter,

Linux does that. 2.6.22. The reason I submitted this patch is that I ran
into this bug. My server advertises (AUTH_SYS, AUTH_NONE), with
AUTH_NONE giving degraded access. The older clients are ok, since
mount.nfs enforces the AUTH_SYS default. Then a new client (2.6.22)
came in and I went scratching my head why it's using AUTH_NONE.

Cheers,
bc

>  As far as I know, all servers, which support exporting with AUTH_NONE,
>  always map the incoming uid and gid(s) to the anonymous uid and gid when
>  they process the request for a file system which is exported with AUTH_NONE.
>  It doesn't seem to matter what the incoming authentication flavor was.
>
>     Thanx...
>
>        ps
>
