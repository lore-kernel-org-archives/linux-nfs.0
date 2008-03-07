From: "bc Wong" <bcwalrus@gmail.com>
Subject: Re: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Fri, 7 Mar 2008 10:59:30 -0800
Message-ID: <f88853200803071059yf523114wcabb12fdeee7b8d6@mail.gmail.com>
References: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>
	 <629ABBF6-C368-44AC-B4B9-471296229325@oracle.com>
	 <f88853200803071011j3a70b0abka9142396d3275b10@mail.gmail.com>
	 <47D18983.4080507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Chuck Lever" <chuck.lever@oracle.com>, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:62730 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbYCGS7c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2008 13:59:32 -0500
Received: by el-out-1112.google.com with SMTP id v27so835932ele.17
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2008 10:59:31 -0800 (PST)
In-Reply-To: <47D18983.4080507@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 7, 2008 at 10:29 AM, Peter Staubach <staubach@redhat.com> wrote:
>  Actually, NFS servers that support AUTH_NONE, map the uid and gid to the
>  anonymous uid and gids for access to file systems which are exported
>  AUTH_NONE.  It doesn't seem to matter what authentication flavor that
>  the client uses.
>
>        ps

Hi Peter,

My concern is that a server supports both AUTH_SYS and AUTH_NONE,
where AUTH_SYS would give you the regular access, and AUTH_NONE
would give the anon access as you described, which is typically a
degraded read-only view. Therefore it's bad for the client to choose
AUTH_NONE in this case, especially since the server presents
AUTH_SYS *before* AUTH_NONE.

I'll test more with AUTH_NONE on Solaris. Is there any specific setup
you'd like me to verify?

Thanks,
bc
