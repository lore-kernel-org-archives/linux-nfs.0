From: Steve Dickson <SteveD@redhat.com>
Subject: pynfs Server failures
Date: Mon, 25 Jan 2010 10:30:49 -0500
Message-ID: <4B5DB929.6020504@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	CAI Qian <caiqian@redhat.com>
To: Bruce Fields <bfields@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44862 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab0AYPax (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 10:30:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce,

During our Fedora Testing effort we have  identified the following
pynfs failures when testing with a kernel-2.6.33 and a very current
nfs-utils...  At one point I thought there was a list of known pynfs 
failures. If so, how does this list match up? any thing new? 
Anything jumping out that we really should fix?

steved.


[root@ibm-hs21-01 pynfs]# ./testserver.py localhost:/nfs --maketree all
CID1     st_setclientid.testClientReboot                          : WARNING
           Trying to use old stateid after SETCLIENTID_CONFIRM
           purges state should return NFS4ERR_OLD_STATEID,
           instead got NFS4ERR_BAD_STATEID
CID6     st_setclientid.testNoConfirm                             : FAILURE
           OPEN using clientid that was never confirmed should
           return NFS4ERR_STALE_CLIENTID, instead got
           NFS4ERR_EXPIRED
CIDCF2   st_setclientidconfirm.testBadConfirm                     : FAILURE
           SETCLIENTID_CONFIRM with case not covered in RFC,
           seems most likely should do nothing and should return
           NFS4_OK, instead got NFS4ERR_CLID_INUSE
COMP3    st_compound.testBadTags                                  : FAILURE
           Compound with invalid utf8 tag '\xc0\xc1' should
           return NFS4ERR_INVAL, instead got NFS4_OK
COMP6    st_compound.testLongCompound                             : FAILURE
           COMPOUND with len=150 argarry got RPCError:
           MSG_ACCEPTED: GARBAGE_ARGS, expected NFS4ERR_RESOURCE
CR13     st_create.testDots                                       : FAILURE
           Trying to CREATE a dir named '.' should return NFS4_OK
           or NFS4ERR_BADNAME, instead got NFS4ERR_INVAL
CR14     st_create.testSlash                                      : FAILURE
           Creation of dir named 'CR14/foo' should return
           NFS4ERR_BADNAME or NFS4ERR_BADCHAR, instead got
           NFS4ERR_INVAL
LINK4a   st_link.testCfhLink                                      : FAILURE
           LINK with <cfh> not a directory should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_SYMLINK
LINK8    st_link.testInvalidUtf8                                  : FAILURE
           LINK with invalid utf8 name LINK8/\xc0\xc1 should
           return NFS4ERR_INVAL, instead got NFS4_OK
LINK9    st_link.testDots                                         : FAILURE
           Trying to make a hardlink named '.' should return
           NFS4_OK or NFS4ERR_BADNAME, instead got NFS4ERR_INVAL
LOCK8c   st_lock.testNonzeroLockSeqid                             : WARNING
           LOCK with newlockowner's lockseqid=1 should return
           NFS4ERR_BAD_SEQID, instead got NFS4_OK
LOCK18   st_lock.testFairness                                     : WARNING
           Locking is not fair
LOCK19   st_lock.testBlockPoll                                    : WARNING
           Locking is not fair
LOCK21   st_lock.testBlockingQueue                                : WARNING
           Locking is not fair
LOCK22   st_lock.testLongPoll                                     : WARNING
           Locking is not fair
LOOK6    st_lookup.testNonAccessable                              : FAILURE
           LOOKUP object in a dir with mode=000 should return
           NFS4ERR_ACCESS, instead got NFS4_OK
LOOK7    st_lookup.testInvalidUtf8                                : FAILURE
           LOOKUP object with invalid utf-8 name \xc0\xc1 should
           return NFS4ERR_INVAL, instead got NFS4ERR_NOENT
LOOK9    st_lookup.testUnaccessibleDir                            : FAILURE
           LOOKUP off of dir with mode=0 should return
           NFS4ERR_ACCESS, instead got NFS4_OK
LOOKP2a  st_lookupp.testLink                                      : FAILURE
           LOOKUPP with non-dir <cfh> should return
           NFS4ERR_NOTDIR, instead got NFS4ERR_SYMLINK
OPCF3a   st_openconfirm.testLink                                  : FAILURE
           OPEN_CONFIRM of a nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_SYMLINK
OPDG9a   st_opendowngrade.testLink                                : WARNING
           OPENDOWNGRADE with nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
OPDG9b   st_opendowngrade.testBlock                               : WARNING
           OPENDOWNGRADE with nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
OPDG9c   st_opendowngrade.testChar                                : WARNING
           OPENDOWNGRADE with nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
OPDG9d   st_opendowngrade.testDir                                 : WARNING
           OPENDOWNGRADE with nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
OPDG9f   st_opendowngrade.testFifo                                : WARNING
           OPENDOWNGRADE with nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
OPDG9s   st_opendowngrade.testSocket                              : WARNING
           OPENDOWNGRADE with nonfile object should return
           NFS4ERR_INVAL, instead got NFS4ERR_BAD_STATEID
OPEN13   st_open.testInvalidUtf8                                  : FAILURE
           Trying to open file with invalid utf8 name
           OPEN13/\xc0\xc1 should return NFS4ERR_INVAL, instead
           got NFS4_OK
OPEN16   st_open.testClaimPrev                                    : WARNING
           Trying to OPEN with CLAIM_PREVIOUS should return
           NFS4ERR_RECLAIM_BAD, instead got NFS4ERR_NO_GRACE
OPEN17   st_open.testModeChange                                   : FAILURE
           Opening file OPEN17 with mode=000 should return
           NFS4ERR_ACCESS, instead got NFS4_OK
OPEN19   st_open.testShareConflict2                               : FAILURE
           Trying to deny write permissions to others when don't
           have write permissions should return NFS4ERR_ACCESS,
           instead got NFS4_OK
OPEN23b  st_open.testDenyRead3a                                   : FAILURE
           Read an access_write file should return NFS4_OK,
           instead got NFS4ERR_IO
RD4      st_read.testLargeCount                                   : WARNING
           READ returned 1048576 characters, expected 9000000
RD12     st_read.testOpenMode                                     : FAILURE
           READ with file opened in WRITE mode should return
           NFS4ERR_OPENMODE, instead got NFS4ERR_IO
RDDR11   st_readdir.testUnaccessibleDir                           : FAILURE
           READDIR of directory with mode=0 should return
           NFS4ERR_ACCESS, instead got NFS4_OK
RDDR12   st_readdir.testUnaccessibleDirAttrs                      : FAILURE
           READDIR of directory with mode=0 should return
           NFS4ERR_ACCESS, instead got NFS4_OK
RM5      st_remove.testNonUTF8                                    : FAILURE
           Trying to remove file with invalid utf8 name
           RM5/\xc0\xc1 should return NFS4ERR_INVAL, instead got
           NFS4ERR_NOENT
RM7      st_remove.testDots                                       : WARNING
           REMOVE nonexistant '.' should return NFS4ERR_BADNAME,
           instead got NFS4ERR_NOENT
RNM8     st_rename.testBadutf8Oldname                             : FAILURE
           RENAME with non-UTF8 oldname RNM8/\xc0\xc1 should
           return NFS4ERR_INVAL, instead got NFS4ERR_NOENT
RNM9     st_rename.testBadutf8Newname                             : FAILURE
           RENAME with non-UTF8 newname RNM9/\xc0\xc1 should
           return NFS4ERR_INVAL, instead got NFS4_OK
RNM10    st_rename.testDotsOldname                                : WARNING
           RENAME from nonexistant '.' should return
           NFS4ERR_BADNAME, instead got NFS4ERR_NOENT
RNM11    st_rename.testDotsNewname                                : FAILURE
           RENAME from nonexistant '.' should return
           NFS4ERR_BADNAME, instead got NFS4ERR_INVAL
RNM16    st_rename.testDirToFullDir                               : FAILURE
           RENAME dir1 into existing, nonempty dir2 should return
           NFS4ERR_EXIST, instead got NFS4ERR_NOTEMPTY
SATT1a   st_setattr.testLink                                      : FAILURE
           Set attrs {33: 480} not equal to got attrs {33: 511}
SATT9    st_setattr.testNonUTF8                                   : UNSUPPORTED
           FATTR4_MIMETYPE not supported
SATT12a  st_setattr.testSizeLink                                  : FAILURE
           SETATTR(FATTR4_SIZE) of a symlink should return
           NFS4ERR_INVAL, instead got NFS4ERR_SYMLINK
SEC6     st_secinfo.testInvalidUtf8                               : FAILURE
           SECINFO of non-existant file with invalid utf8 name
           '\xc0\xc1' should return NFS4ERR_INVAL, instead got
           NFS4ERR_NOENT
SEC7     st_secinfo.testRPCSEC_GSS                                : FAILURE
           SECINFO returned mechanism list without RPCSEC_GSS
WRT5     st_write.testLargeData                                   : FAILURE
           error: [Errno 32] Broken pipe
**************************************************
Command line asked for 587 of 637 tests
Of those: 8 Skipped, 31 Failed, 17 Warned, 531 Passed
