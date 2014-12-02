Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:20308 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325AbaLBRVE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 12:21:04 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [nfs-utils PATCH v2 00/17] A few enhancements to mountstats.py
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Date: Tue, 2 Dec 2014 12:20:57 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7AB38ECF-9B0B-4E0D-ADE9-A3DA4783C2CF@oracle.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott-

On Nov 26, 2014, at 2:13 PM, Scott Mayhew <smayhew@redhat.com> wrote:

> Changes since v1:
> 
> - Changed the parsing to use the argparse module instead of optparse
> 
> - Added per-mountpoint headers to the output of 'mountstats --rpc'
> 
> - Revamped the ms-nfsstat command to take a variable list of mountpoints
>  (so now mountstats, ms-iostat, and ms-nfsstat all behave in the same
>  manner).  Added -3 and -4 options which behave the same way they do in
>  nfsstat.c.  The output doesn't still doesn't match up 100% with that
>  of nfsstat.c though (I'm just taking the first 12 characters of the
>  operation name and converting them to lowercase to use as labels, while
>  nfsstat.c defines its own labels, but also it looks to me like nfsstat.c
>  is missing some operations altoegether).
> 
> - Updated the man page for mountstats and added man pages for ms-iostat
>  and ms-nfsstat.
> 
> These are also available in the 'mountstats-improvements-v2' branch at
> https://github.com/scottmayhew/nfs-utils.git

Tried this out. The features I normally use seem to be
working OK.

It appears that python-argparse is not installed by
default on some systems. That would have to be added
as an RPM dependency. No big deal, but it might be
nice to add exception processing in the scripts to deal
with not finding it (print a polite error message
instead of spewing a backtrace).

A couple of nits with the man pages:

Filenames (like /proc/self/mountstats) are typically
italicized.

In the synopses, the closing square brace is unmatched.
Either use just an ellipsis, or add a matching opening
brace. Have a look at how this is done in other man
pages.

At this point I wouldn’t call it a full “review” or
“test” but I’ll keep playing with it. I don’t have any
objection to merging these, and you could address my
nit-picks with subsequent patches if you want.

> Original cover letter:
> 
> -------------------8<------------------
> 
> The following patches add a couple of enhancements to mountstats.py.  I
> also fixed a few bugs I encountered along the way.  Highlights include:
> 
> - added support for -f/--file to allow stats to be parsed from an
>  aritrary input file instead of /proc/self/mountstats
> 
> - added support for -S/--since to show just the changes that have
>  occurred between the current and a previous set of statisics (works
>  with and without the -f option)
> 
> - added support for -R/--raw to generate 'raw' statistics (i.e. in the
>  same format as /proc/self/mountstats).  It's intended to be used with
>  the -f and -S options.
> 
> - implemented the ms-nfsstat command to generate client-side
>  nfsstat-like statisics (only works with a single mountpoint)
> 
> My motivation for these changes was so that I could take various copies
> of /proc/self/mountstats and massage them into data that I could feed
> into the 'report' option of Dros's nfsometer tool for scenarios where
> it's not feasible to run nfsometer itself (e.g. systems where we can't
> start with an 'idle' state (i.e. no NFS filesystems initially
> mounted), systems with multiple NFS filesystems mounted, and workloads
> that can't easily be boiled down into an nfsometer workload file or run
> via the custom workload environment variables).
> 
> Scott Mayhew (17):
>  mountstats: Fix up NFS event counters
>  mountstats: Add lists of various counters
>  mountstats: Refactor __parse_nfs_line and __parse_rpc_line
>  mountstats: Refactor compare_iostats
>  mountstats: Convert existing option parsing to use the argparse module
>  mountstats: Make ms-iostat output match that of nfs-iostat.py
>  mountstats: Make print_iostat_summary handle newly appearing mounts
>  mountstats: Add support for -f/--file to the mountstats and ms-iostat
>    commands
>  mountstats: Add support for -S/--since to the mountstats and ms-iostat
>    commands
>  mountstats: Fix IndexError in __parse_nfs_line
>  mountstats: Allow mountstats_command to take a variable number of
>    mountpoints
>  mountstats: Add support for -R/--raw to mountstats_command
>  mountstats: Implement nfsstat_command
>  mountstats: Updated the mountstats(8) man page.
>  mountstats: Added man page for ms-iostat(8)
>  mountstats: Added man page for ms-nfsstat(8)
>  mountstats: add ms-iostat and ms-nfsstat to Makefile.am
> 
> tools/mountstats/Makefile.am    |   4 +-
> tools/mountstats/mountstats.man |  45 +-
> tools/mountstats/mountstats.py  | 904 ++++++++++++++++++++++++++++------------
> tools/mountstats/ms-iostat.man  |  64 +++
> tools/mountstats/ms-nfsstat.man |  49 +++
> 5 files changed, 777 insertions(+), 289 deletions(-)
> create mode 100644 tools/mountstats/ms-iostat.man
> create mode 100644 tools/mountstats/ms-nfsstat.man
> 
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



