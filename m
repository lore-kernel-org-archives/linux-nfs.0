Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:51339 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756705Ab1H3VD7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 17:03:59 -0400
Message-ID: <4E5D5001.2030906@panasas.com>
Date: Tue, 30 Aug 2011 14:02:57 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Add a cache for fs_locations information
References: <20110829185115.3413.92459.stgit@matisse.1015granger.net>  <20110830151845.4dec5b40@tlielax.poochiereds.net>  <852F14A9-7826-47A0-BCD6-D5D46E38A39C@oracle.com>  <4E5D46EB.7030102@panasas.com> <1314736451.10572.45.camel@lade.trondhjem.org>
In-Reply-To: <1314736451.10572.45.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/30/2011 01:34 PM, Trond Myklebust wrote:
> On Tue, 2011-08-30 at 13:24 -0700, Boaz Harrosh wrote: 
>> On 08/30/2011 01:00 PM, Chuck Lever wrote:
>> <>
>>>>
>>>> Won't the above check be rather expensive? You'll need to do a 
>>>> getxattr call on almost every path component of every lookup,
>>>> right?
>>>>
>>>> I may be misremembering your talk from connectathon, but I thought
>>>> you were planning to use a well-known mode for junctions that would
>>>> cut down on the number of unnecessary getxattrs...
>>>
>>> Yes, that's the plan.  To reduce overhead, the S_ISVTX bit must be
>>> set before NFSD does the expensive xattr test.  
> 
> ...and mode bits otherwise set to 0 so nobody can access the mounted-on
> directory.
> 
>> from: stat(2) - Linux man page
>>
>> The 'sticky' bit (S_ISVTX) on a directory means that a file in that
>> directory can be renamed or deleted only by the owner of the file, 
>> by the owner of the directory, and by a privileged process.
>>
>> Please explain how does it work? Once the junction is followed and
>> mounted then the mode-bits get changed to the destination directory's
>> mode bits? So the Server's junction mode-bits are never exposed, except
>> in a local-fs file access on the server?
> 
> Yes.
> 
Nice trick. Thanks
