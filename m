From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4] nfs-utils: add testing infrastructure to nfs-utils
 (try #6)
Date: Tue, 12 Jan 2010 07:25:54 -0500
Message-ID: <4B4C6A52.9010209@RedHat.com>
References: <1262962563-5554-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310Ab0ALM0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2010 07:26:11 -0500
In-Reply-To: <1262962563-5554-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/08/2010 09:55 AM, Jeff Layton wrote:
> This is an updated patchset for adding test infrastructure to nfs-utils.
> The main differences in this patchset are:
> 
> 1) some bugfixes in the statdb_dump program
> 
> 2) an extra check for root privs in the t0001 test. If the caller
> doesn't have root privs, then the test is skipped
> 
> This patchset is intended as a starting point for an automated test
> suite for nfs-utils. The idea here is to start simply and add a suite of
> tests that we can run via "make check" -- the standard automake method
> for running tests.
> 
> Clearly there are limits to what we can test without a multi-host test
> harness. My hope is that this should help keep us from breaking basic
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
> unmon functionality with statd. Adding more tests should be fairly simple
> to do.
> 
> Jeff Layton (4):
>   nfs-utils: make private cookie to hex conversion a library routine
>   nfs-utils: introduce new statd testing simulator
>   nfs-utils: add statdb_dump utility
>   nfs-utils: add initial tests for statd that run via "make check"
> 
Committed...

steved.
