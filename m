Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbaKEWHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 17:07:52 -0500
Date: Wed, 5 Nov 2014 17:07:49 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfs-utils RFC PATCH 00/15] A few enhancements to mountstats.py
Message-ID: <20141105220749.GI4532@tonberry.usersys.redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
 <69F60F0B-331B-40F8-B740-12568C0132F4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <69F60F0B-331B-40F8-B740-12568C0132F4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Wed, 05 Nov 2014, Chuck Lever wrote:

> Hi Scott-
> 
> > On Nov 5, 2014, at 12:00 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> > 
> > The following patches add a couple of enhancements to mountstats.py.  I
> > also fixed a few bugs I encountered along the way.  Highlights include:
> > 
> > - added support for -f/--file to allow stats to be parsed from an
> >  aritrary input file instead of /proc/self/mountstats
> > 
> > - added support for -S/--since to show just the changes that have
> >  occurred between the current and a previous set of statisics (works
> >  with and without the -f option)
> > 
> > - added support for -R/--raw to generate 'raw' statistics (i.e. in the
> >  same format as /proc/self/mountstats).  It's intended to be used with
> >  the -f and -S options.
> > 
> > - implemented the ms-nfsstat command to generate client-side
> >  nfsstat-like statisics (only works with a single mountpoint)
> > 
> > My motivation for these changes was so that I could take various copies
> > of /proc/self/mountstats and massage them into data that I could feed
> > into the 'report' option of Dros's nfsometer tool for scenarios where
> > it's not feasible to run nfsometer itself (e.g. systems where we can't
> > start with an 'idle' state (i.e. no NFS filesystems initially
> > mounted), systems with multiple NFS filesystems mounted, and workloads
> > that can't easily be boiled down into an nfsometer workload file or run
> > via the custom workload environment variables).
> 
> Do you have a git repo I can pull these from to try out?

You can pull them from https://github.com/scottmayhew/nfs-utils.git
commit ids f9c256040^..6a43a1599

-Scott

> 
> 
> > Scott Mayhew (15):
> >  mountstats: Fix up NFS event counters
> >  mountstats: Add lists of various counters
> >  mountstats: Refactor __parse_nfs_line and __parse_rpc_line
> >  mountstats: Refactor compare_iostats
> >  mountstats: Convert existing option parsing to use the getopt module
> >  mountstats: Make ms-iostat output match that of nfs-iostat.py
> >  mountstats: Make print_iostat_summary handle newly appearing mounts
> >  mountstats: Add support for -f/--file to the mountstats and ms-iostat
> >    commands
> >  mountstats: Add support for -S/--since to the mountstats and ms-iostat
> >    commands
> >  mountstats: Fix IndexError in __parse_nfs_line
> >  mountstats: Allow mountstats_command to take a variable number of
> >    mountpoints
> >  mountstats: Add support for -R/--raw to mountstats_command
> >  mountstats: Implement nfsstat_command
> >  mountstats: Remove the --start and --end options
> >  mountstats: Update the help output
> > 
> > tools/mountstats/mountstats.py | 730 ++++++++++++++++++++++++++++++-----------
> > 1 file changed, 544 insertions(+), 186 deletions(-)
> > mode change 100644 => 100755 tools/mountstats/mountstats.py
> > 
> > -- 
> > 1.9.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

