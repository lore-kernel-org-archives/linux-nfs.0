Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43933 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757635Ab2CMV3z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 17:29:55 -0400
Date: Tue, 13 Mar 2012 17:29:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "Ted Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120313212947.GK31995@pad.fieldses.org>
References: <20120306151816.GB32282@thunk.org>
 <20120306152842.GA8339@pad.fieldses.org>
 <20120309205148.GB5635@thunk.org>
 <20120312150912.GB12440@thunk.org>
 <20120312154921.GB17153@pad.fieldses.org>
 <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
 <4F5FB771.9010805@fastmail.fm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F5FB771.9010805@fastmail.fm>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 10:09:05PM +0100, Bernd Schubert wrote:
> Hmm, there must have gone something wrong on merging,

In that case one approach would be to rebase your last-sent patches on
to the same base as Ted's versions, confirm that one still works and the
other doesn't, and do a diff....

> my own test
> also fails
> 
> http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/
> 
> (Sorry, it does not say 'failure', but one needs to compare the file
> names and telldir-offset numbers)
> 
> I think I will continue in the morning as its already 1 a.m. here.

OK, thanks for following up!

--b.
