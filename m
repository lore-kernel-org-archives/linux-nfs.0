Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966225AbaLLTO6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2014 14:14:58 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBCJEwm3017952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:14:58 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBCJEwgM003715
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:14:58 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sBCJEvje000335
	for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 14:14:57 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sBCJEvOg000334
	for linux-nfs@vger.kernel.org; Fri, 12 Dec 2014 14:14:57 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v4 00/14] A few enhancements to mountstats.py
Date: Fri, 12 Dec 2014 14:14:43 -0500
Message-Id: <1418411697-65535-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are also available in the 'mountstats-improvements-v4' branch at
https://github.com/scottmayhew/nfs-utils.git

v4 changes:

- SteveD was not a fan of the ms-iostat and ms-nfsstat command names. 
  Rather than think up new names, I decided to make these all sub-commands.
  If no sub-command is given by the user then the 'mountstats' sub-command
  will run by default (so any existing scripts that run older versions of
  the mountstats command should still work).

- Rather than have 3 tiny man pages, I documented the main command and the
  three sub-commands on a single man page.

v3 changes:

- Rebased on top of the lastest mountstats version

- Added exception processing to fail more gracefully when the argparse
  module is not installed

- Corrected some issues with the man pages (filenames not italicized,
  unmatched braces in the synopses)

v2 changes:

- Changed the parsing to use the argparse module instead of optparse

- Added per-mountpoint headers to the output of 'mountstats --rpc'

- Revamped the ms-nfsstat command to take a variable list of mountpoints
  (so now mountstats, ms-iostat, and ms-nfsstat all behave in the same
  manner).  Added -3 and -4 options which behave the same way they do in
  nfsstat.c.  The output doesn't still doesn't match up 100% with that
  of nfsstat.c though (I'm just taking the first 12 characters of the
  operation name and converting them to lowercase to use as labels, while
  nfsstat.c defines its own labels, but also it looks to me like nfsstat.c
  is missing some operations altoegether).

- Updated the man page for mountstats and added man pages for ms-iostat
  and ms-nfsstat.

Original cover letter:

-------------------8<------------------

The following patches add a couple of enhancements to mountstats.py.  I
also fixed a few bugs I encountered along the way.  Highlights include:

- added support for -f/--file to allow stats to be parsed from an
  aritrary input file instead of /proc/self/mountstats

- added support for -S/--since to show just the changes that have
  occurred between the current and a previous set of statisics (works
  with and without the -f option)

- added support for -R/--raw to generate 'raw' statistics (i.e. in the
  same format as /proc/self/mountstats).  It's intended to be used with
  the -f and -S options.

- implemented the ms-nfsstat command to generate client-side
  nfsstat-like statisics (only works with a single mountpoint)

My motivation for these changes was so that I could take various copies
of /proc/self/mountstats and massage them into data that I could feed
into the 'report' option of Dros's nfsometer tool for scenarios where
it's not feasible to run nfsometer itself (e.g. systems where we can't
start with an 'idle' state (i.e. no NFS filesystems initially
mounted), systems with multiple NFS filesystems mounted, and workloads
that can't easily be boiled down into an nfsometer workload file or run
via the custom workload environment variables).

Scott Mayhew (14):
  mountstats: Fix up NFS event counters
  mountstats: Add lists of various counters
  mountstats: Refactor __parse_nfs_line and __parse_rpc_line
  mountstats: Refactor compare_iostats
  mountstats: Convert existing option parsing to use the argparse module
  mountstats: Make the iostat sub-command output match that of
    nfs-iostat.py
  mountstats: Make print_iostat_summary handle newly appearing mounts
  mountstats: Add support for -f/--file
  mountstats: Add support for -S/--since
  mountstats: Fix IndexError in __parse_nfs_line
  mountstats: Allow mountstats_command to take a variable number of
    mountpoints
  mountstats: Add support for -R/--raw to mountstats_command
  mountstats: Implement the nfsstat sub-command
  mountstats: Updated the mountstats(8) man page.

 tools/mountstats/mountstats.man | 142 +++++-
 tools/mountstats/mountstats.py  | 927 ++++++++++++++++++++++++++++------------
 2 files changed, 775 insertions(+), 294 deletions(-)

-- 
1.9.3

