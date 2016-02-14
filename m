Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36378 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbcBNVar (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Feb 2016 16:30:47 -0500
Subject: Re: getrichacl(1) man page review comments
To: Andreas Gruenbacher <agruenba@redhat.com>
References: <56B770B6.7040803@gmail.com> <56B77139.4080209@gmail.com>
Cc: mtk.manpages@gmail.com, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-ext4@vger.kernel.org, xfs@oss.sgi.com,
        lkml <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <56C0F1FF.3050003@gmail.com>
Date: Sun, 14 Feb 2016 22:30:39 +0100
MIME-Version: 1.0
In-Reply-To: <56B77139.4080209@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andreas,

Here's a few more comments on the current getrichacl(1) page
that I fetched from the git repo.

> .\"
> .\" RichACL Manual Pages
> .\"
> .\" Copyright (C) 2015,2016  Red Hat, Inc.
> .\" Written by Andreas Gruenbacher <agruenba@redhat.com>
> .\" This is free documentation; you can redistribute it and/or
> .\" modify it under the terms of the GNU General Public License as
> .\" published by the Free Software Foundation; either version 2 of
> .\" the License, or (at your option) any later version.
> .\"
> .\" The GNU General Public License's references to "object code"
> .\" and "executables" are to be interpreted as the output of any
> .\" document formatting or typesetting system, including
> .\" intermediate and printed output.
> .\"
> .\" This manual is distributed in the hope that it will be useful,
> .\" but WITHOUT ANY WARRANTY; without even the implied warranty of
> .\" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> .\" GNU General Public License for more details.
> .\"
> .\" You should have received a copy of the GNU General Public
> .\" License along with this manual.  If not, see
> .\" <http://www.gnu.org/licenses/>.
> .\"
> .TH GETRICHACL 7 2015-09-01 "Linux" "Rich Access Control Lists"
> 
> .SH NAME
> getrichacl \- Get Rich Access Control Lists
> 
> .SH SYNOPSIS
> .B getrichacl
> .RI [ option "]... [" file ]...
> 
> .SH DESCRIPTION
> For each file,
> .B getrichacl
> displays the file name and the file's Rich Access Control List (RichACL).
> 
> The output format of
> .B getrichacl
> is as follows:

Add a blank line here.

> .fam C
> .RS
> .nf
>  1:  file:
>  2:      flags:a
>  3:      owner:rwp-------------::mask
>  4:      group:r-p-------------::mask
>  5:      other:r---------------::mask
>  6:     owner@:rwp-------------::allow
>  7:   user:foo:r-p-------------::allow
>  8:     group@:r-p-------------::allow
>  9:  group:bar:r-p-------------::allow
> 10:  everyone@:r---------------::allow
> 11:
> .fi
> .RE
> .fam T
> 
> Line 1 contains the file name, followed by a colon.
> 
> Line 2 contains the ACL flags. This line is omitted if no flags are set.
> 
> Lines 3--5 indicate the owner, group, and other file masks, which are only
> shown if the \fB\-\-raw\fR option is specified.
> 
> Lines 6--10 indicate different ACL entries for the file owner
> .RB ( owner@ ),
> user \fIfoo\fR, the owning group
> .RB ( group@ ),
> group \fIbar\fR, and for everyone
> .RB ( everyone@ ).
> 
> A blank line follows at the end.
> 
> The default output format uses the single-letter forms of flags and
> permissions, identifiers of ACL entries are right justified, permissions are
> vertically aligned, and permissions which are always granted
> .RB ( read_attributes ", " read_acl ", " synchronize )
> are omitted. See the
> .BR richacl (7)
> manual page for the defined flags and permissions.
> 
> By default,
> .B getrichacl
> displays the effective permissions remaining after applying the file masks to
> the ACL.  The file masks and underlying NFSv4 ACL can be displayed with the
> \fB\-\-raw\fR option.
> 
> When
> .B getrichacl
> is used on a file that does not have a RichACL or on a filesystem that does not
> support RichACLs,
> .B getrichacl

Replace the previous line with "it".

> displays the access permissions defined by the traditional file permission bits
> as a RichACL. When
> .B getrichacl
> is used on a file that has a POSIX ACL (see
> .BR acl (5)),
> it prints an error message.
> 
> .SH OPTIONS
> .TP
> \fB\-\-long\fR, \fB\-l\fR
> Display access masks and flags in their long form.
> .TP
> \fB\-\-full\fR
> Also show permissions which are always implicitly allowed.
> .TP
> \fB\-\-raw\fR
> Show ACLs as stored on the file system, including the file masks. Implies
> \fB\-\-full\fR.
> .TP
> \fB\-\-unaligned\fR
> Do not align ACL entries or pad missing permissions with '-'.
> .TP
> \fB\-\-numeric-ids\fR
> Display numeric user and group IDs instead of names.
> .TP
> \fB\-\-access\fR [=\fIuser\fR[:\fIgroup\fR:...]}, \fB\-a\fR[\fIuser\fR[:\fIgroup\fR:...]}
> Instead of showing the ACL, show which permissions the user running the command
> has for the specified file(s).  When \fIuser\fR is specified, show which
> permissions the specified user has instead.  If \fIuser\fR is followed by a
> colon and a (possibly empty) list of groups, assume that \fIuser\fR is a member
> in the specified groups; otherwise,
> .BR getgrouplist (3)
> is used to determine the groups \fIuser\fR is a member in.

s/in/of/

> .TP
> \fB\-\-version\fR, \fB\-v\fR
> Display the version of
> .B getrichacl
> and exit.
> .TP
> \fB\-\-help\fR, \fB\-h\fR
> Display command-line usage help text.
> 
> .SH AUTHOR
> Written by Andreas Grünbacher <agruenba@redhat.com>.
> 
> Please send your bug reports, suggested features and comments to the above address.
> 
> .SH CONFORMING TO
> Rich Access Control Lists are Linux-specific.
> 
> .SH SEE ALSO
> .BR richacl (7),
> .BR setrichacl (1)

Cheers,

Michael
