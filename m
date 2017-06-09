Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26087 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751572AbdFISEd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jun 2017 14:04:33 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFSv4: cinfo->atomic and file creation
Date: Fri, 9 Jun 2017 14:04:26 -0400
Message-Id: <33567B9C-C04A-436F-A4F6-F5AB745D3323@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

As we discussed yesterday, I'm concerned about the test in
_nfs4_proc_open that uses the values of the cinfo.before and
cinfo.after fields without checking cinfo.atomic.

2288         if (o_arg->open_flags & O_CREAT) {
2289                 if (o_arg->open_flags & O_EXCL)
2290                         data->file_created = 1;
2291                 else if (o_res->cinfo.before != o_res->cinfo.after)
2292                         data->file_created = 1;
2293                 if (data->file_created || dir->i_version != o_res->cinfo.after)
2294                         update_changeattr(dir, &o_res->cinfo,
2295                                         o_res->f_attr->time_start);
2296         }

Line 2291 is the issue.

Suppose the server filesystem substitutes a weak ctime for
the change attribute. Sometimes when a file is successfully
created on the server, the ctime of the parent doesn't
change. This test then fails and leaves file_created set
to zero.

Later, nfs4_opendata_access looks at file_created. If not
set, the access check fails and open(2) returns EACCES as
a result, even though the file was created successfully
and OPEN returned NFS4_OK.

You mentioned that the server should set cinfo.atomic to
be false when a weak ctime is used as the change attribute.
Will that help in this case?


--
Chuck Lever



