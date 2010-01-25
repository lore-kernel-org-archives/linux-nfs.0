Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35692 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab0AYSmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 13:42:05 -0500
Date: Mon, 25 Jan 2010 13:43:33 -0500
From: Bruce Fields <bfields@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        CAI Qian <caiqian@redhat.com>
Subject: Re: pynfs Server failures
Message-ID: <20100125184333.GC8244@fieldses.org>
References: <4B5DB929.6020504@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B5DB929.6020504@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 25, 2010 at 10:30:49AM -0500, Steve Dickson wrote:
> Hey Bruce,
> 
> During our Fedora Testing effort we have  identified the following
> pynfs failures when testing with a kernel-2.6.33 and a very current
> nfs-utils...  At one point I thought there was a list of known pynfs 
> failures.

Did you see the mail I sent you last week?  Especially:

	http://linux-nfs.org/pipermail/pnfs/2010-January/010008.html

> If so, how does this list match up? any thing new? 
> Anything jumping out that we really should fix?

Personally I've been ignoring the tests that don't pass and just
rerunning the rest regularly to spot regressions.  I think that's the
best use of pynfs for now.

Some of the failures are unimportant or questionable, so "this patch
fixes pynfs test XXXYYY" is never enough to justify applying
anything--we also need to check the spec and/or consider the effect on
client-side behavior.

Anyway, may still be worth another look at the results, so here goes:

> [root@ibm-hs21-01 pynfs]# ./testserver.py localhost:/nfs --maketree all
> CID1     st_setclientid.testClientReboot                          : WARNING
>            Trying to use old stateid after SETCLIENTID_CONFIRM
>            purges state should return NFS4ERR_OLD_STATEID,
>            instead got NFS4ERR_BAD_STATEID
> CID6     st_setclientid.testNoConfirm                             : FAILURE
>            OPEN using clientid that was never confirmed should
>            return NFS4ERR_STALE_CLIENTID, instead got
>            NFS4ERR_EXPIRED
> CIDCF2   st_setclientidconfirm.testBadConfirm                     : FAILURE
>            SETCLIENTID_CONFIRM with case not covered in RFC,
>            seems most likely should do nothing and should return
>            NFS4_OK, instead got NFS4ERR_CLID_INUSE

Medium priority to fix.

> COMP3    st_compound.testBadTags                                  : FAILURE
>            Compound with invalid utf8 tag '\xc0\xc1' should
>            return NFS4ERR_INVAL, instead got NFS4_OK

UTF8 failures are by design; ignore. Omitting similar results in the
following.

> COMP6    st_compound.testLongCompound                             : FAILURE
>            COMPOUND with len=150 argarry got RPCError:
>            MSG_ACCEPTED: GARBAGE_ARGS, expected NFS4ERR_RESOURCE

Low priority to fix.

> CR13     st_create.testDots                                       : FAILURE
>            Trying to CREATE a dir named '.' should return NFS4_OK
>            or NFS4ERR_BADNAME, instead got NFS4ERR_INVAL
> CR14     st_create.testSlash                                      : FAILURE
>            Creation of dir named 'CR14/foo' should return
>            NFS4ERR_BADNAME or NFS4ERR_BADCHAR, instead got
>            NFS4ERR_INVAL

Medium priority to fix. Omitting similar failures in the following.

> LINK4a   st_link.testCfhLink                                      : FAILURE
>            LINK with <cfh> not a directory should return
>            NFS4ERR_NOTDIR, instead got NFS4ERR_SYMLINK

I think current behavior may actually be correct; check the spec and
behavior on other filesystems.  Low priority.  Omitting similar failures
in the following.

> LOCK8c   st_lock.testNonzeroLockSeqid                             : WARNING
>            LOCK with newlockowner's lockseqid=1 should return
>            NFS4ERR_BAD_SEQID, instead got NFS4_OK

The spec doesn't require this; we should probably remove this test.

> LOCK18   st_lock.testFairness                                     : WARNING
>            Locking is not fair
> LOCK19   st_lock.testBlockPoll                                    : WARNING
>            Locking is not fair
> LOCK21   st_lock.testBlockingQueue                                : WARNING
>            Locking is not fair
> LOCK22   st_lock.testLongPoll                                     : WARNING
>            Locking is not fair

Medium priority to fix.  I have patches that would need updating.

> LOOK6    st_lookup.testNonAccessable                              : FAILURE
>            LOOKUP object in a dir with mode=000 should return
>            NFS4ERR_ACCESS, instead got NFS4_OK

This happens when tests are run with root and root-squashing is
disabled:

	http://linux-nfs.org/pipermail/nfsv4/2006-January/thread.html#3305

I believe current behavior is correct, but it might be worth another
look.  Low priority.  Omitting similar results in the following.

> OPDG9a   st_opendowngrade.testLink                                : WARNING
>            OPENDOWNGRADE with nonfile object should return
>            NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
> OPDG9b   st_opendowngrade.testBlock                               : WARNING
>            OPENDOWNGRADE with nonfile object should return
>            NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
> OPDG9c   st_opendowngrade.testChar                                : WARNING
>            OPENDOWNGRADE with nonfile object should return
>            NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
> OPDG9d   st_opendowngrade.testDir                                 : WARNING
>            OPENDOWNGRADE with nonfile object should return
>            NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
> OPDG9f   st_opendowngrade.testFifo                                : WARNING
>            OPENDOWNGRADE with nonfile object should return
>            NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
> OPDG9s   st_opendowngrade.testSocket                              : WARNING
>            OPENDOWNGRADE with nonfile object should return
>            NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID

Not sure if that's worth fixing.  Very low priority.

> OPEN16   st_open.testClaimPrev                                    : WARNING
>            Trying to OPEN with CLAIM_PREVIOUS should return
>            NFS4ERR_RECLAIM_BAD, instead got NFS4ERR_NO_GRACE

Current behavior probably correct.

> OPEN19   st_open.testShareConflict2                               : FAILURE
>            Trying to deny write permissions to others when don't
>            have write permissions should return NFS4ERR_ACCESS,
>            instead got NFS4_OK

Test is wrong; patch submitted to Fred.

> OPEN23b  st_open.testDenyRead3a                                   : FAILURE
>            Read an access_write file should return NFS4_OK,
>            instead got NFS4ERR_IO

Might be worth investigating.

> RD4      st_read.testLargeCount                                   : WARNING
>            READ returned 1048576 characters, expected 9000000

Ignore.

> RD12     st_read.testOpenMode                                     : FAILURE
>            READ with file opened in WRITE mode should return
>            NFS4ERR_OPENMODE, instead got NFS4ERR_IO

Eh, maybe should be fixed.  Low priority.

> RNM16    st_rename.testDirToFullDir                               : FAILURE
>            RENAME dir1 into existing, nonempty dir2 should return
>            NFS4ERR_EXIST, instead got NFS4ERR_NOTEMPTY

Might be worth checking.  Low priority.

> SATT1a   st_setattr.testLink                                      : FAILURE
>            Set attrs {33: 480} not equal to got attrs {33: 511}

Probably worth investigating.  Medium priority.

> SEC7     st_secinfo.testRPCSEC_GSS                                : FAILURE
>            SECINFO returned mechanism list without RPCSEC_GSS

Configure krb5 on your test client and server if you want to run those
tests.

> WRT5     st_write.testLargeData                                   : FAILURE
>            error: [Errno 32] Broken pipe

Ignore.

--b.
