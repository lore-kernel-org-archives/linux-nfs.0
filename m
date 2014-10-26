Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:44302 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbaJZVra convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Oct 2014 17:47:30 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: NFSv4 idmap misbehavior
Date: Sun, 26 Oct 2014 17:47:21 -0400
Message-Id: <70DD1EAE-3001-46E7-92D6-AEB928E8FBA1@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David-

I’m looking into some odd NFS idmapper behavior, and I’ve bisected
the problem to this commit (merged in 3.13):

> commit b2a4df200d570b2c33a57e1ebfa5896e4bc81b69
> Author: David Howells <dhowells@redhat.com>
> Date:   Tue Sep 24 10:35:18 2013 +0100
> 
>     KEYS: Expand the capacity of a keyring
>     
>     Expand the capacity of a keyring to be able to hold a lot more keys by using
>     the previously added associative array implementation.  Currently the maximum
>     capacity is:
>     
>     (PAGE_SIZE - sizeof(header)) / sizeof(struct key *)
>     
>     which, on a 64-bit system, is a little more 500.  However, since this is being
>     used for the NFS uid mapper, we need more than that.  The new implementation
>     gives us effectively unlimited capacity.
>     
>     With some alterations, the keyutils testsuite runs successfully to completion
>     after this patch is applied.  The alterations are because (a) keyrings that
>     are simply added to no longer appear ordered and (b) some of the errors have
>     changed a bit.
>     
>     Signed-off-by: David Howells <dhowells@redhat.com>


The problem occurs when running on RHEL6 with an upstream kernel
against a Solaris 11 update 2 server. I am able to reproduce this
with 3.17. Notably I’m not able to reproduce this with a newer
user space (tried with F19), nor with a Linux NFS server.

To reproduce it, I’ll start a long-running cthon04 test on an
NFS mount.

[cel@dali cthon04-x86_64]$ ./server -a -N10

Just after starting the test, in another window:

# grep id_ /proc/keys
03515452 I--Q---     1   9m 3b010000     0     0 id_resolv gid:users@oracle.com: 4
1c6ebd43 I--Q---     1 perm 1f3f0000     0 65534 keyring   _uid_ses.0: 1
249f8fdb I--Q---     1   9m 3b010000     0     0 id_resolv gid:root@oracle.com: 2
2da69ca9 I--Q---     1 perm 3f3f0000     0     0 keyring   .id_resolver_child_1: 4
37df5ceb I--Q---     1   9m 3b010000     0     0 id_resolv uid:cel@oracle.com: 5
38810f75 I------     1 perm 1f030000     0     0 keyring   .id_resolver: 1
3e7df923 I--Q---     1   9m 3b010000     0     0 id_resolv uid:root@oracle.com: 2

After the test has been running for ten minutes, the id_resolv
keys expire, and id_legacy keys appear. Before the above commit,
the id_resolv keys would simply be refreshed and operation
would continue normally.

# grep id_ /proc/keys
00f0a664 I--Q-N-     1  42s 3b010000     0     0 id_legacy uid:cel@oracle.com
03515452 I--Q---     1 expd 3b010000     0     0 id_resolv gid:users@oracle.com: 4
0efeaada I--Q-N-     1  53s 3b010000     0     0 id_legacy uid:root@oracle.com
12d6cd15 I--Q-N-     1  42s 3b010000     0     0 id_legacy gid:users@oracle.com
1c6ebd43 I--Q---     1 perm 1f3f0000     0 65534 keyring   _uid_ses.0: 1
249f8fdb I--Q---     1 expd 3b010000     0     0 id_resolv gid:root@oracle.com: 2
2da69ca9 I--Q---     1 perm 3f3f0000     0     0 keyring   .id_resolver_child_1: 4
2e7150a3 I--Q-N-     1  53s 3b010000     0     0 id_legacy gid:root@oracle.com
37df5ceb I--Q---     1 expd 3b010000     0     0 id_resolv uid:cel@oracle.com: 5
38810f75 I------     1 perm 1f030000     0     0 keyring   .id_resolver: 5
3e7df923 I--Q---     1 expd 3b010000     0     0 id_resolv uid:root@oracle.com: 2

Subsequently cthon04 fails when it tries to start another pass:

**  CHILD pass 1 results: 64/64 pass, 0/0 warn, 0/0 fail (pass/total).
Congratulations, you passed the locking tests!
... Pass 8 ...

rm: cannot remove `/mnt/monet/dali.test': Operation not permitted
Starting BASIC tests: test directory /mnt/monet/dali.test (arg: -t)
mkdir: cannot create directory `/mnt/monet/dali.test': File exists

./test1: File and directory creation test
rm: cannot remove `/mnt/monet/dali.test': Operation not permitted
./test1: (/home/cel/src/cthon04-x86_64/basic) can't remove old test directory /mnt/monet/dali.test
basic tests failed
Tests failed, leaving /mnt/monet mounted
[cel@dali cthon04-x86_64]$

And ID mapping on the test mount is broken. “dali.test” is the
test directory, but all other files on that mount have bogus
ownership.

[cel@dali cthon04-x86_64]$ ls -l /mnt/monet
total 38995
drwxr-xr-x  2 4294967294 4294967294             4098 Oct 15 22:59 310
-rw-------  1 4294967294 4294967294         10485760 Oct 15 23:00 aio-testfile
-rw-r--r--  1 4294967294 4294967294                0 Oct 15 22:38 client.out
drwxr-xr-x 12 4294967294 4294967294               12 Oct 15 11:47 clients
drwxrwxrwx  2 4294967294 4294967294                2 Oct 26 17:16 dali.test
drwxr-xr-x  3 4294967294 4294967294                3 Oct 15 22:54 dbench
-rw-------  1 4294967294 4294967294                0 Oct 15 22:53 file
 . . . 

Restarting the tests or removing the test directory by hand
results in “Operation not permitted."

After several minutes, all expired id_ keys are purged:

1c6ebd43 I--Q---     1 perm 1f3f0000     0 65534 keyring   _uid_ses.0: 1
2da69ca9 I--Q---     1 perm 3f3f0000     0     0 keyring   .id_resolver_child_1: empty
38810f75 I------     1 perm 1f030000     0     0 keyring   .id_resolver: 1

And cthon04 is able to run again.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



