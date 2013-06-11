Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756835Ab3FKUGL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 16:06:11 -0400
Date: Tue, 11 Jun 2013 16:06:10 -0400
To: Frank Filz <ffilz-lists@mindspring.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>, ffilz@us.ibm.com
Subject: Re: Some pynfs updates
Message-ID: <20130611200610.GB29634@fieldses.org>
References: <51B75979.5070300@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51B75979.5070300@mindspring.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 11, 2013 at 10:08:09AM -0700, Frank Filz wrote:
> Please pull this branch from github:
> https://github.com/ffilz/pynfs/commits/master

Thanks, applied (actually from git://github.com/ffilz/pynfs.git master).

> commit a6548ab80a68787dc3fcb5c8531d4d189d77c3a9
> Author: Frank S. Filz <ffilz@us.ibm.com>
> Date:   Wed May 1 16:06:56 2013 -0700
> 
> Make mode 000 tests expect NFS4_OK when run as root
> 
> They will warn if NFS4ERR_ACCESS is returned.

... though I'm not sure about this one.  root-squashing is completely
normal, I'm not convinced it merits a warning.

--b.
