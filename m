Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:59794 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab2CMVKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 17:10:13 -0400
Date: Tue, 13 Mar 2012 17:10:09 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120313211009.GA11969@thunk.org>
References: <20120306020819.GH31388@pad.fieldses.org>
 <20120306151816.GB32282@thunk.org>
 <20120306152842.GA8339@pad.fieldses.org>
 <20120309205148.GB5635@thunk.org>
 <20120312150912.GB12440@thunk.org>
 <20120312154921.GB17153@pad.fieldses.org>
 <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120313203446.GB21991@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 04:34:46PM -0400, J. Bruce Fields wrote:
> > 
> > Thanks! I'm also just going to work on it (just noticed your mail
> > while on vacation ...).

Brend, thanks!!

Bruce, random question --- do you know what the copyright and
licensing terms are for the connectathon test suite?  It occurs to me
that it might be good to get some of these tests into xfstests, given
that you mentioned that the telldir test was failing even when run on
a local file system.  That says to me this is a good file system level
test that we should try to get into xfstests if possible.

Getting it into xfstests would also tend to reduce the chance of
regressions, since I always run xfstests before I submit patches (and
in fact I did run xfstests before sending you a pull request Bernd's
patches --- and I'm glad your testing caught the problem when mine
didn't!)

Thanks,

     	       	      	       		- Ted
