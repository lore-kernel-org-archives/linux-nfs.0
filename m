Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52610 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754592AbcK1QdY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Nov 2016 11:33:24 -0500
Date: Mon, 28 Nov 2016 11:33:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Tom Haynes <loghyr@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH pynfs 00/12] Flex File support
Message-ID: <20161128163321.GB30805@parsley.fieldses.org>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1480228001-64821-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 26, 2016 at 10:26:29PM -0800, Tom Haynes wrote:
> I wanted to add client support for the flex file layout.
> 
> Note, I did not add pynfs as a flag because I didn't want to
> mess up with any existing uses of it.
> 
> The other major change here is in closing all opened
> files and destroying all clientids. With all the tests
> which run against my server, there are no longer any
> open files. There are however 11 clientids remaining.
> 
> I will track those down.
> 
> fwiw - these are in my staging branch at git://linux-nfs.org/~loghyr/pynfs.git

Thanks!  I'll try these and take a look.

How did you notice all the leftover state?  I run with a pretty short
lease time (to speed testing), so I guess the leftover state must expire
too quickly to cause me problems.

Anyway it's good to have that cleaned up.

--b.

> 
> Tom Haynes (12):
>   According to RFC7863, this is not an array
>   Close the files opened in the OPEN tests
>   Some more file closes to cleanup state on the server
>   Get rid of the client records as well as the session records
>   Really, really close those open temp files to remove state on the
>     server
>   Add xdr for Flex Files Layout Type
>   Simple tests of the flex file layout type
>   Add a check to see if NFS4ERR_OLD_STATEID is issued on concurrent
>     layoutgets
>   Check that the flex file access uid/gid are correct for the different
>     iomodes
>   FFLS1: Simulate LAYOUTSTATS for 20 small file creations
>   Factor out checking seqid for flex file layouts
>   Add layoutstats tests for flex files
> 
>  nfs4.1/nfs4client.py                        |   5 +-
>  nfs4.1/server41tests/__init__.py            |   1 +
>  nfs4.1/server41tests/environment.py         |   5 +
>  nfs4.1/server41tests/st_current_stateid.py  |  36 +-
>  nfs4.1/server41tests/st_debug.py            |  18 +-
>  nfs4.1/server41tests/st_flex.py             | 594 ++++++++++++++++++++++++++++
>  nfs4.1/server41tests/st_open.py             |  29 +-
>  nfs4.1/server41tests/st_reclaim_complete.py |   4 +
>  nfs4.1/server41tests/st_rename.py           |   4 +
>  nfs4.1/server41tests/st_secinfo.py          |  20 +-
>  nfs4.1/server41tests/st_sequence.py         |   8 +
>  nfs4.1/testmod.py                           |   1 +
>  nfs4.1/xdrdef/nfs4.x                        |  99 ++++-
>  13 files changed, 812 insertions(+), 12 deletions(-)
>  create mode 100644 nfs4.1/server41tests/st_flex.py
> 
> -- 
> 2.3.6
> 
