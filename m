Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33557 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbcBGQay (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Feb 2016 11:30:54 -0500
Subject: getrichacl(1) man page review comments
To: Andreas Gruenbacher <agruenba@redhat.com>
References: <56B770B6.7040803@gmail.com>
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
Message-ID: <56B77139.4080209@gmail.com>
Date: Sun, 7 Feb 2016 17:30:49 +0100
MIME-Version: 1.0
In-Reply-To: <56B770B6.7040803@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Andreas,

Here, some comments on the getrichacl(1) page.

> .\"
> .\" Richacl Manual Pages
> .\"
> .\" Copyright (C) 2015  Red Hat, Inc.
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
> .RI [ OPTION "]... [" FILE ]...

In man-pages, at least, the convention is to use lower case for these
pieces (and thus through the remainder of the page), so:

> .RI [ option "]... [" file ]...

> .SH DESCRIPTION
> For each file, getrichacl displays the file name and Rich Access Control List

For man-pages, at least, the convention is that the references to the
function/command name explained in the page are bold, do:

.BR getrichacl

> (richacl).

For what it's worth, I think it would be worthwhile to start with
a consistent abbreviation comment here (and use it throughout all of the
man pages): "RichACL" (or "richACL"), rather than "richacl"; that seems
more consistent with the traditional abbreviation "ACL".

> 
> By default, getrichacl displays the effective permissions remaining after

.BR getrichacl

> applying the file masks to the ACL.  The file masks and underlying NFSv4 ACL
> can be displayed with the \-\-raw option.

Use
.BR \-\-raw

> 
> The output format of getrichacl is as follows:

.BR getrichacl

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
> shown if the \-\-raw option is specified.
> 
> Lines 6--10 indicate different ACL entries for the file owner
> .RB ( owner@ ),
> user foo, the owning group
> .RB ( group@ ),
> group bar, and for everyone

.IR bar ,

> .RB ( everyone@ ).
> 
> A blank line follows at the end.
> 
> By default, getrichacl displays the the single-letter forms of flags and

.BR getrichacl

s/the the/the/

> permissions, the identifiers of ACL entryies are right justified, the

s/entryies/entries/

> permissions are vertically aligned, and permissions which are always
> granted
> .RB ( read_attributes ", " read_acl ", " synchronize )
> are omitted. See the richacl(7) manual page for the defined flags and

Use
.BR richachl (7)
for page cross references.

> permissions.
> 
> When getrichacl is used on a file that does not have a richacl or on a

.BR getrichacl

> filesystem that does not support richacls, getrichacl displays the access

.BR getrichacl

> permissions defined by the traditional file permission bits as a richacl. When
> getrichacl is used on a file that has a POSIX ACL, it prints an error message.

.BR getrichacl

And then:

[...] has a POSIX ACL (see
.BR acl (7)), it prints [...]
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
> Show acls as stored on the file system including the file masks. Implies

s/axls/ACLs/

> \fB\-\-full\fR.
> .TP
> \fB\-\-unaligned\fR
> Do not align ACL entries or pad missing permissions with '-'.
> .TP
> \fB\-\-numeric-ids\fR
> Display numeric user and group IDs instead of names.
> .TP
> \fB\-\-access\fR [=\fIuser\fR[:\fIgroup\fR:...]}, \fB\-a\fR[\fIuser\fR[:\fIgroup\fR:...]}
> Instead of the ACL, show which permissions the caller or a specified user has

"caller"? "the user running the command, "

> for file(s).  When a list of groups is given, this overrides the groups the

s/file(s)/specified file(s)/

> user is in.

The preceding text is not very clear.

> .TP
> \fB\-\-version\fR, \fB\-v\fR
> Display the version of getrichacl and exit.

.BR getrichacl

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
> .BR setrichacl (1),
> .BR richacl (7)

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
