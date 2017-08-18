Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49704 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbdHRQxV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 12:53:21 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: NFSv4: cinfo->atomic and file creation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1503074395.44656.14.camel@primarydata.com>
Date: Fri, 18 Aug 2017 12:53:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <795F514B-3478-4DF5-AEF7-22F8411A1509@oracle.com>
References: <33567B9C-C04A-436F-A4F6-F5AB745D3323@oracle.com> <1503074395.44656.14.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 18, 2017, at 12:39 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-06-09 at 14:04 -0400, Chuck Lever wrote:
>> Hi Trond-
>> 
>> As we discussed yesterday, I'm concerned about the test in
>> _nfs4_proc_open that uses the values of the cinfo.before and
>> cinfo.after fields without checking cinfo.atomic.
>> 
>> 2288         if (o_arg->open_flags & O_CREAT) {
>> 2289                 if (o_arg->open_flags & O_EXCL)
>> 2290                         data->file_created = 1;
>> 2291                 else if (o_res->cinfo.before != o_res-
>>> cinfo.after)
>> 2292                         data->file_created = 1;
>> 2293                 if (data->file_created || dir->i_version !=
>> o_res->cinfo.after)
>> 2294                         update_changeattr(dir, &o_res->cinfo,
>> 2295                                         o_res->f_attr-
>>> time_start);
>> 2296         }
>> 
>> Line 2291 is the issue.
>> 
>> Suppose the server filesystem substitutes a weak ctime for
>> the change attribute. Sometimes when a file is successfully
>> created on the server, the ctime of the parent doesn't
>> change. This test then fails and leaves file_created set
>> to zero.
> 
> A server which uses a ctime with insufficient resolution is in
> violation of the requirements for a change attribute. The spec
> explicitly disallows it in https://tools.ietf.org/html/rfc5661#section-
> 5.8.1.4
> 
> IOW: the remainder of the spec (including the definition of OPEN) does
> expect that you can rely on the change attribute for detecting file
> changes.

Fair enough.

It's been suggested that Linux should prevent NFSv4 access of
any filesystem that can't support the change attribute
adequately. That would block existing xfs filesystems with
older on-disk formats. Any xfs filesystem formatted on a RHEL7
system has one of these older formats.

This is actually a pretty difficult problem for legacy file
systems. In this case I wonder if RFC 5661 is impractically
draconian.

The alternative is that the Linux NFS server will have to
recognize such filesystems and somehow generate proper change
attributes for them, even though it can't save them on disk.


>> Later, nfs4_opendata_access looks at file_created. If not
>> set, the access check fails and open(2) returns EACCES as
>> a result, even though the file was created successfully
>> and OPEN returned NFS4_OK.
>> 
>> You mentioned that the server should set cinfo.atomic to
>> be false when a weak ctime is used as the change attribute.
>> Will that help in this case?
> 
> No. The cinfo.atomic flag is there to let you know that the change you
> are seeing in the directory was caused by the operation that just
> executed. If it is set to "false" then that does not really tell you
> much about whether or not you can trust that a change occurred.

A client can't trust the change attribute when cinfo.atomic
is false. In that case, the client might depend on other means
to ensure correct operation.


--
Chuck Lever



