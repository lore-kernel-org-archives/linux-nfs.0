Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36425 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826Ab2CMUet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Mar 2012 16:34:49 -0400
Date: Tue, 13 Mar 2012 16:34:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, "Ted Ts'o" <tytso@mit.edu>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120313203446.GB21991@fieldses.org>
References: <20120306000837.GA17164@thunk.org>
 <20120306020819.GH31388@pad.fieldses.org>
 <20120306151816.GB32282@thunk.org>
 <20120306152842.GA8339@pad.fieldses.org>
 <20120309205148.GB5635@thunk.org>
 <20120312150912.GB12440@thunk.org>
 <20120312154921.GB17153@pad.fieldses.org>
 <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F5FA827.8020606@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 09:03:51PM +0100, Bernd Schubert wrote:
> On 03/13/2012 09:01 PM, J. Bruce Fields wrote:
> >On Mon, Mar 12, 2012 at 06:22:50PM -0400, bfields wrote:
> >>On Mon, Mar 12, 2012 at 11:49:21AM -0400, J. Bruce Fields wrote:
> >>>On Mon, Mar 12, 2012 at 11:09:12AM -0400, Ted Ts'o wrote:
> >>>>On Fri, Mar 09, 2012 at 03:51:48PM -0500, Ted Ts'o wrote:
> >>>>>
> >>>>>Linus in general doesn't like cross tree merges (or any extraneous
> >>>>>merges) unless they are absolutely necessary; but then, he trusts git
> >>>>>merges more than many of us do.  :-)
> >>>>>
> >>>>>I've put the the patch series on a separate patch, with a signed tag, at:
> >>>>>
> >>>>>      git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git nfs-ext4-premerge
> >>>>>
> >>>>>Can you confirm that you've pulled it into your tree and it's landed
> >>>>>in linux-next?  I probably won't bother pulling it in mine unless
> >>>>>there is definitely a merge conflict that I need to resolve.  (I've
> >>>>>checked and there do not appear to be any against linux-next as of
> >>>>>last night.)
> >>>>
> >>>>Ping?
> >>>
> >>>Whoops, sorry.
> >>>
> >>>Looks perfect, thanks for handling these!
> >>>
> >>>I'm running them through my usual regression tests
> >>
> >>Urgh, I'm seeing a failure on the telldir test (part of the "special"
> >>connectathon tests).  I haven't looked at what it's trying to do yet.
> >>Reproduceable even just on a local filesystem without NFS involved.  If
> >>someone wants to look at it, you can just do:
> >>
> >>	git clone git://linux-nfs.org/~bfields/cthon04.git
> >>	cd cthon04
> >>	make
> >>	NFS_TESTDIR=/somewhere_on_an_ext4_fs/TMP ./runtests -s
> >>
> >>(Or after running that, more specifically,
> >>
> >>	cd /somewhere_on_an_ext4_fs/TMP/
> >>	./telldir
> >>
> >>)
> >>
> >>I'll look at it tomorrow.
> >
> >Looks like seekdir is just not accepting an offset returned from
> >getdents:
> >
> >	openat(AT_FDCWD, "telldir-test", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
> >	getdents(3, {...{d_ino=20386, d_off=5728083968307607285, d_reclen=24, d_name="192"}...} = 4848
> >	lseek(3, 5728083968307607285, SEEK_SET) = -1 EINVAL (Invalid argument)
> >
> >Still investigating.
> 
> Thanks! I'm also just going to work on it (just noticed your mail
> while on vacation ...).

OK, good.  You can probably figure this out faster than me....

--b.
