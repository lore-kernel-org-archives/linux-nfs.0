From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils
	(try #3)
Date: Wed, 6 Jan 2010 14:17:06 -0500
Message-ID: <20100106191706.GE6612@fieldses.org>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, chuck.lever@oracle.com,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49802 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab0AFTQU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 14:16:20 -0500
In-Reply-To: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 05, 2010 at 10:40:32AM -0500, Jeff Layton wrote:
> This is an updated patchset for adding test infrastructure to nfs-utils.
> The main differences from the last patchset are:
> 
> 1) renamed "statdtest" to "nsm_client", since that's a bit more
> descriptive of its actual purpose.
> 
> 2) added a very simple "statdb_dump" program that dumps out the more
> interesting fields of the of the NSM monitor DB. The inital mon/unmon
> test now uses that program to verify the contents of the DB after the
> MON call.
> 
> This patchset is intended as a starting point for an automated test
> suite for nfs-utils. The idea here is to start simply and add a suite of
> tests that we can run via "make check" -- the standard automake method
> for running tests.
> 
> Clearly there are limits to what we can test without a multi-host test
> harness.

This probably just shows I'm not reading carefully, but: are you
requiring root, and messing with their existing nfs configuration at
all?

For the export stuff it would also be great to have some tests that set
up a few dummy exports (using tmpfs?) and tried to mount them (just over
loopback), but I'd be afraid someone would try to run "make check" on
their production server.  So I'm not sure where to put that kind of
test.

--b.

> My hope is that this should help keep us from breaking basic
> functionality by allowing us to test it in a very simple fashion. At
> some point in the future we should also consider how to best handle
> multi-machine testing, but I see that as complimenting this code rather
> than replacing it.
> 
> For this set, the focus is on testing statd, which is particularly
> susceptible to subtle breakage. Problems with it are often not noticed
> until lock recovery breaks, and that may greatly lag the actual
> breakage.
> 
> To faciitate statd testing, I've added a "nsm_client" program that can
> serve as a synthetic statd client and an NLM simulator. It's very
> loosely based on the old statd simulator code. That program is dependent
> on some of Chuck Lever's recent statd patches -- notably the ones that
> break out common NSM code into libnsm.a.
> 
> For this initial drop, I'm just adding a single test that tests mon and
> unmon functionality with statd. Adding more tests should fairly simple
> to do.
> 
> Jeff Layton (3):
>   nfs-utils: introduce new statd testing simulator
>   nfs-utils: add statdb_dump utility
>   nfs-utils: add initial tests for statd that run via "make check"
> 
>  Makefile.am                          |    2 +-
>  configure.ac                         |    4 +-
>  tests/Makefile.am                    |   13 +
>  tests/nsm_client/Makefile.am         |   45 ++++
>  tests/nsm_client/README              |   12 +
>  tests/nsm_client/nlm_sm_inter.x      |   43 +++
>  tests/nsm_client/nsm_client.c        |  465 ++++++++++++++++++++++++++++++++++
>  tests/statdb_dump.c                  |   75 ++++++
>  tests/t0001-statd-basic-mon-unmon.sh |   55 ++++
>  tests/test-lib.sh                    |   41 +++
>  10 files changed, 753 insertions(+), 2 deletions(-)
>  create mode 100644 tests/Makefile.am
>  create mode 100644 tests/nsm_client/Makefile.am
>  create mode 100644 tests/nsm_client/README
>  create mode 100644 tests/nsm_client/nlm_sm_inter.x
>  create mode 100644 tests/nsm_client/nsm_client.c
>  create mode 100644 tests/statdb_dump.c
>  create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
>  create mode 100755 tests/test-lib.sh
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
