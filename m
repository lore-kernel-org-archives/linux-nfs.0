Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59233 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754350Ab1AKIRT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jan 2011 03:17:19 -0500
Message-ID: <4D2C120B.6090205@panasas.com>
Date: Tue, 11 Jan 2011 10:17:15 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: =?x-gbk?Q?=D5=C5=D6=BE=C1=D6?= <zhilin5832@163.com>
CC: nfsv4@ietf.org, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pNFS Control Protocol
References: <429fef15.1271f.12d6fbeb6b7.Coremail.zhilin5832@163.com>
In-Reply-To: <429fef15.1271f.12d6fbeb6b7.Coremail.zhilin5832@163.com>
Content-Type: text/plain; charset=x-gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello 张志林,

On 2011-01-10 13:45, 张志林 wrote:
> Hi,
>      Recently,I am doing some work about pNFS. And I have some question about Control Protocol.
>      1) Can we define a minimum set of operations in  Control Protocol to support?

Good question! :)

> If the answer is yes,then what are they?

As of NFSv4.1 the files layout control protocol is out of scope of main protocol
and it is left for the server implementation to define.

Defining such a protocol could be part of NFSv4.2 or a IETF protocol on its own
(specified by the nfsv4 working group)

>      2) In Solaris pNFS Control Protocol 1.1,there are several issues to handle;
>         (http://wikis.sun.com/display/NFS/pNFS+Control+Protocol+Specification)
>              MDS and DS restart / network partition indication.

When exporting a clustered file system such as GFS2 on linux this is often solved
at the file system level rather than at the pNFS level.

>              Filehandle, File StateID, and layout validation.

Yes.

>              Client access validation (has access to MDS-FS and is using appropriate sec! urity mechanism).

Yes.

>              Reporting of DS resources.

Sounds good in principle.
I wouldn't put it as part of a minimal set of operation.

>              Management of Inter-DS data movement.

Not applicable yet for the linux implementations.

>              MDS Proxy I/O.

This is really implementation specific.
spnfs just use NFS the the DSs for that.

>              DS state invalidation.

Stateid in general should be global as the DS must recognize and validate the stateid
the client presents for I/O - which is either an open, lock, or delegation stateid.

>          I hope that you can provide me some more detailed description and of design,
> such as weather daemon is used on DS and MDS to support pNFS Control Protocol.

In linux, there is no such protocol in use yet.
Spnfs has no control protocol implemented (and there's no one currently working on it).
The DLM based server (for GFS2 and OCFS2) use distributed locking over shared storage to
coordinate access to files from the MDS and DSs.  Writes are served only by the MDS, therefore
the implementation "goes-by" without implementing the control protocol.  However, there are
some requirements by the spec. that it does meet like denying DS access to wrong byte ranges
(sparse striping)

>  
> Best wishes

Thanks for working on this!

Benny

>                                                                                                                           Yours
>                                                                                                                                                  Zhilin Zhang
> 
> 
> 
> 
> 
> 
