Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:35490 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbcBWTBV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Feb 2016 14:01:21 -0500
Received: by mail-vk0-f46.google.com with SMTP id e6so170452733vkh.2
        for <linux-nfs@vger.kernel.org>; Tue, 23 Feb 2016 11:01:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHc6FU67LnV7-roofFe1y_uTfvgwonRZimyu7Wn1CDRzwHZJSw@mail.gmail.com>
References: <56B770B6.7040803@gmail.com>
	<56B77262.7090107@gmail.com>
	<CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
	<56C0F23C.7030902@gmail.com>
	<CAHc6FU4CCrcrA6=oCiq2A5rGd9CCGELaTZq6tGpmd2jcV_Zp4A@mail.gmail.com>
	<56CA2EEB.9080504@gmail.com>
	<CAHc6FU46vO8NM3cvFH7b8X7U9R+m6wcYj8EQKVnSQkiY3Q051A@mail.gmail.com>
	<56CC3B4A.7070204@gmail.com>
	<CAHc6FU67LnV7-roofFe1y_uTfvgwonRZimyu7Wn1CDRzwHZJSw@mail.gmail.com>
Date: Tue, 23 Feb 2016 20:01:20 +0100
Message-ID: <CAHc6FU4FR577X=sZAPUXhCL4SUfrRYTHw9_byehZqwYyBOhQiA@mail.gmail.com>
Subject: Re: richacl(7) man page review comments
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
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
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 23, 2016 at 4:09 PM, Andreas Gruenbacher
<agruenba@redhat.com> wrote:
> Hi Michael,
>
> On Tue, Feb 23, 2016 at 11:58 AM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> On 02/22/2016 03:46 PM, Andreas Gruenbacher wrote:
>>> On Sun, Feb 21, 2016 at 10:40 PM, Michael Kerrisk (man-pages) <mtk.manpages@gmail.com> wrote:
>>>> I've once more pulled from the latest git; here's some more comments.
>>>
>>> thanks again. I've updated the repo with your changes.
>>
>> Next round :-). Just a few quick comments while I'm on a train ride.
>
> applied, thanks.

I've fixed the following additional problems:

> diff --git a/man/richacl.7 b/man/richacl.7
> index acdff31..1c82644 100644
> --- a/man/richacl.7
> +++ b/man/richacl.7
> @@ -30,10 +30,8 @@
>  .SH NAME
>  richacl \- Rich Access Control Lists
>  .SH DESCRIPTION
> -Rich Access Control Lists (RichACLs) are an extension of the POSIX file
> -permission model (see
> -.BR acl (5))
> -to support
> +Rich Access Control Lists (RichACLs) are an extension of the traditional POSIX
> +file permission model to support
>  .URL https://tools.ietf.org/rfc/rfc5661.txt "NFSv4 Access Control Lists"
>  on local and remote-mounted filesystems.

RichACLs are an extension of the traditional POSIX file permission
model, not of the POSIX ACL model.

Unfortunately, there doesn't seem to be a man-page covering POSIX File
Access Permissions as in Appendix A of
http://www.bestbits.at/richacl/draft-gruenbacher-nfsv4-acls-in-posix-00.html.

A lot of the gaps between paragraphs were wrong when rendered for printing.

The modification dates were outdated.

Andreas
