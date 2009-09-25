From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Ping: [pnfs] [RFC 1/1] nfs4: optionally return status from state_manager
Date: Fri, 25 Sep 2009 17:19:10 +0300
Message-ID: <4ABCD15E.2020009@panasas.com>
References: <4A9EDDE6.1090308@panasas.com>	 <1251990924-3904-1-git-send-email-bhalevy@panasas.com>	 <4ABC477E.4060709@panasas.com>	 <1253885382.31072.14.camel@heimdal.trondhjem.org>	 <4ABCCB4D.4020603@panasas.com> <1253888019.31072.31.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:23449 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752675AbZIYOTI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Sep 2009 10:19:08 -0400
In-Reply-To: <1253888019.31072.31.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 25, 2009, 17:13 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Fri, 2009-09-25 at 16:53 +0300, Benny Halevy wrote:
>> That scenario is caused when the server's /etc/exports
>> is badly configured, where the export entry for nfsv4
>> (fsid=0) exports a non-existing path.
>>
>> I agree that the server should not return ENOENT
>> for PUTROOTFH as it contradicts the spec.
>> NFS4ERR_SERVERFAULT seems more appropriate.
> 
> Indeed.
> 
>> The main reason for getting the failure from
>> the state engine in nfsv4.1 is that we need to
>> create a session before nfs4_path_walk in nfs4_create_server
>> and we do that using the state manager.
>> In the nfsv4.0 case we create no state at this point.
> 
> OK, so this particular case, there is no state recovery possible at all.
> If so, why not just label the cl_cons_state as NFS_CS_IRRECOVERABLE (or
> possibly NFS_CS_SERVERFAULT) instead of trying to overload it with an
> error value that nobody can do anything about?

OK.  I'll try this approach then.

Thanks!

Benny

> 
> I'd say that if you want to pass the error value to the administrator,
> then the right way to do that would be via a printk. Something along the
> lines of
> 
> printk("NFSv4: Server %s returned an illegal error %d when getting the
> root filehandle\n");
> 
> However, I'm not really convinced that is necessary...
> 
