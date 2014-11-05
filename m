Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932190AbaKERBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:14 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1DjQ004048
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:14 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1Co3027838
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:13 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Cgl000898
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:12 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1CMv000897
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:12 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 00/15] A few enhancements to mountstats.py
Date: Wed,  5 Nov 2014 12:00:57 -0500
Message-Id: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Scott Mayhew (15):
  mountstats: Fix up NFS event counters
  mountstats: Add lists of various counters
  mountstats: Refactor __parse_nfs_line and __parse_rpc_line
  mountstats: Refactor compare_iostats
  mountstats: Convert existing option parsing to use the getopt module
  mountstats: Make ms-iostat output match that of nfs-iostat.py
  mountstats: Make print_iostat_summary handle newly appearing mounts
  mountstats: Add support for -f/--file to the mountstats and ms-iostat
    commands
  mountstats: Add support for -S/--since to the mountstats and ms-iostat
    commands
  mountstats: Fix IndexError in __parse_nfs_line
  mountstats: Allow mountstats_command to take a variable number of
    mountpoints
  mountstats: Add support for -R/--raw to mountstats_command
  mountstats: Implement nfsstat_command
  mountstats: Remove the --start and --end options
  mountstats: Update the help output

 tools/mountstats/mountstats.py | 730 ++++++++++++++++++++++++++++++-----------
 1 file changed, 544 insertions(+), 186 deletions(-)
 mode change 100644 => 100755 tools/mountstats/mountstats.py

-- 
1.9.3

