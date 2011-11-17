Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:1918 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825Ab1KQBqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 20:46:30 -0500
Date: Wed, 16 Nov 2011 20:46:15 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: John Hughes <john@calvaedi.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jim Rees <rees@umich.edu>
Message-ID: <76928528.162.1321494375223.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <20111116203119.1d9c0dd6@corrin.poochiereds.net>
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

While I'm not expert in this area, my impression had been that the established
practice was that used with AFS, i.e., run jobs under a process capable of renewing
kerberos tickets, e.g., kstart (http://www.eyrie.org/~eagle/software/kstart/).

Matt

----- "Jeff Layton" <jlayton@redhat.com> wrote:

> The previous situation was also a recipe for disaster, and was often
> cited as a primary reason why people didn't want to deploy kerberized
> NFS. Having everything fall down and go boom when your ticket expires
> is not desirable either.
> 
> I suppose we'll have to agree to disagree on this point. That said,
> I'm
> open to sane suggestions however that don't regress the behavior for
> those users who need to be able to cope with expired tickets.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
