Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33804 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbcBUVBc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Feb 2016 16:01:32 -0500
Subject: Re: richacl(7) man page review comments
To: Andreas Gruenbacher <agruenba@redhat.com>
References: <56B770B6.7040803@gmail.com> <56B77262.7090107@gmail.com>
 <CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
 <56C0F23C.7030902@gmail.com>
 <CAHc6FU4CCrcrA6=oCiq2A5rGd9CCGELaTZq6tGpmd2jcV_Zp4A@mail.gmail.com>
Cc: mtk.manpages@gmail.com, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, lkml <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <56CA25A5.2030100@gmail.com>
Date: Sun, 21 Feb 2016 22:01:25 +0100
MIME-Version: 1.0
In-Reply-To: <CAHc6FU4CCrcrA6=oCiq2A5rGd9CCGELaTZq6tGpmd2jcV_Zp4A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/20/2016 05:37 PM, Andreas Gruenbacher wrote:
> Hi Michael,
> 
> thanks again for all the feedback. I've followed all your suggestions;
> again, please see the github repo for the latest version:
> 
>   https://github.com/andreas-gruenbacher/richacl
> 
> On Sun, Feb 14, 2016 at 10:31 PM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> Hi Andreas,
>>
>> Here's a few more comments on the current richacl(7) page
>> that I fetched from the git repo.
>>

[...]

>>> .HP
>>> .BR dir_inherit "\ (" d ):
>>> The entry is inheritable for directories.
>>
>> "When this flag appears in the ACL entry of a directory, then that entry is
>> inherited by new subdirectories created in the directory."
>>
>> Is that text that I propose correct?
> 
> It's not entirely wrong, but only a small part of the truth. Entries
> are inherited such that the permissions in file_inherit entries become
> effective for access checking for new files, and the permissions in
> dir_inherit entries become effective for access checking for new
> directories, recursively.
> 
> Your feedback prompted me to look into the inheritance flag
> computation more closely once again, and I found bugs. The steps of
> the algorithm are explained in the section "Permissions at
> file-creation time", by the way.

Hmmm... writing and refining documentation helps find code bugs. 
Who knew? :-)

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
