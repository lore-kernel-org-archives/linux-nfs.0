Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58158 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014Ab3FKVB4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 17:01:56 -0400
Date: Tue, 11 Jun 2013 17:01:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Frank Filz <ffilz-lists@mindspring.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>, ffilz@us.ibm.com
Subject: Re: Some pynfs updates
Message-ID: <20130611210155.GD29634@fieldses.org>
References: <51B75979.5070300@mindspring.com>
 <20130611200610.GB29634@fieldses.org>
 <51B78716.30703@mindspring.com>
 <20130611202803.GC29634@fieldses.org>
 <51B7900D.7090704@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51B7900D.7090704@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 11, 2013 at 02:01:01PM -0700, Frank Filz wrote:
> On 06/11/2013 01:28 PM, J. Bruce Fields wrote:
> >On Tue, Jun 11, 2013 at 01:22:46PM -0700, Frank Filz wrote:
> >>On 06/11/2013 01:06 PM, J. Bruce Fields wrote:
> >>>On Tue, Jun 11, 2013 at 10:08:09AM -0700, Frank Filz wrote:
> >>>>Please pull this branch from github:
> >>>>https://github.com/ffilz/pynfs/commits/master
> >>>
> >>>Thanks, applied (actually from git://github.com/ffilz/pynfs.git master).
> >>>
> >>>>commit a6548ab80a68787dc3fcb5c8531d4d189d77c3a9
> >>>>Author: Frank S. Filz <ffilz@us.ibm.com>
> >>>>Date:   Wed May 1 16:06:56 2013 -0700
> >>>>
> >>>>Make mode 000 tests expect NFS4_OK when run as root
> >>>>
> >>>>They will warn if NFS4ERR_ACCESS is returned.
> >>>
> >>>... though I'm not sure about this one.  root-squashing is completely
> >>>normal, I'm not convinced it merits a warning.
> >>
> >>Oh, didn't think about that, good point. Would you like me to submit
> >>a patch to make it an acceptable return?
> >
> >In the uid=0 case, yes, I think that's best.
> 
> If you want to pull again, I just added a new patch to do so.
> 
> Tested the mode000 tests with root, squashed and not, and with a
> non-root user. Pass in all cases against Ganesha.

Thanks!--b.
