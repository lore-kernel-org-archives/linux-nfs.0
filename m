Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:38672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751053Ab2LCSpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2012 13:45:24 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] RFC: enable the use of the KEYRING credential cache
Date: Mon,  3 Dec 2012 13:45:14 -0500
Message-Id: <1354560315-2393-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is a request for comments patch set. It is the nfs-utils portion of a solution for synchronizing the Kerberos credential and gss_context credential destruction.

The keyring is used as it provides a known place for the Kerberos credentials used by NFS, and built-in kernel callbacks that can be used for kerberos credential and gss context synchronization.

The design is for the auth_rpcgss module to register a new key type, the "gss-ctx" key, whose methods can be used for some gss context managment. This key is added to the kerberos keyring and contains any information needed for Kerberos based gss context managememnt.

Currently, the uid is stored in the gss-ctx key and the destroy method is implemented to destroy all Kerberos gss_contexts for the uid.

This design requires new nfslogin/nfslogout programs to be used. The nfslogin and logout programs do two tasks.

1) enforce the keyring nameing convention required for GSSD to use keyrings.
2) create/destroy/update the gss-ctx key used to synhronize the gss context withthe kerberos credential cache.

There are three pieces to this design: GSSD patches, new (yet to be officially written) nfslogin/nfslogout, and KERNEL pactches.

------------------------
GSSD code:
There are two pieces:

1) Enabling GSSD to use the Kerberos KEYRING credential cache - the two patches
2) New nfslogin and nfslogout programs to be used for kerberos NFS mounts.


This code enables GSSD to use the Kerberos 5 supported KEYRING credential cache.
GSSD: Add keyring ccache for machine credential
GSSD: gssd_setup_krb5_user_keyring_ccache

Motivation:
In order for GSSD to use the Krb5 KEYRING credential type, a naming convention
is required. Use the same credential cache naming convention as used for the
FILE or MEMORY credential cache names, without a path name component:

KEYRING:krb5cc_<UID>

------------------------
NEW EXECUTABLES:
Proposed new executable: nfslogin:

This program will kinit -c KEYRING:krb5cc_<UID>, enforcing the keyring naming
convetion required by GSSD, and then create a gss-ctx key which holds the UID
as a payload, and is placed in the krb5cc_<UID> keyring.


What I do for testing is what nfslogin will do:

# kinit -c KEYRING:krb5cc_<UID>
# nfs-add-key UID krb5cc_<UID>


For destruction, I run:

# kdestroy -c KEYRING:krb5cc_<UID> 

The kdestroy removes the krb5cc_<UID> keyring which causes the gss-ctx key to bedestroyed, and the destroy method removes the UID's kerberos gss contexts.

Here is the nfs-add-key userlevel code that creates the gss-ctx key:
#include <sys/types.h>
#include <keyutils.h>
#include <stdio.h>
#include <errno.h>

main (int ac, char **av)
{
        char *keyring_name;
        int uid;
        key_serial_t key_serial, ring_serial;

        if (ac != 3) {
                fprintf(stderr, "Usage: %s <uid> <keyring file name>\n",
                        av[0]);
                return;
        }
        uid = atoi(av[1]);
        keyring_name = av[2];

        fprintf(stderr, "uid: [%d], keyring:[%s]\n", uid, keyring_name);

        ring_serial = request_key("keyring", keyring_name ,NULL,
                                KEY_SPEC_SESSION_KEYRING);
        if (ring_serial < 0) {
                perror("request_key failed\n");
                return;
        }
        key_serial = add_key("gss-ctx","_nfs_gss_", &uid, sizeof(int),
                                ring_serial);
        if (key_serial < 0) {
                perror("add_key failed\n");
                return;
        }

}

Proposed new executable: nfslogout:

This program will call kdestroy -c KEYRING:krb5cc_<UID>, enforcing the naming
convetion required by GSSD. Destroying the krb5cc_<UID> keyring calls the
destroy callback on the gss-ctx key, which in turn uses the UID to search all
rpc_clnt gss_auth Kerberos mechanism credential caches and marks all found
gss credentials as not uptodate. This results in immediate revocation of
NFS access for the UID.

------------------------
KERNEL code:
The kernel portion of this request for comments, patch:
"SUNRPC: new keyring key_type for gss context destruction at kdestroy"
does the following:

- registers a new key_type "gss-ctx" used by nfslogin/nfslogout. nfslogin stores the uid in the key.
- the gss-ctx destroy method uses the stored uid to search all gss_auth kerberos rpc client credential caches for the uid's gss contexts and marks them as not up to date.

-----------------------
TESTING

Here is the rpc.gssd -K -f -vvv output for mount:

[root@fedora-64-2 andros]# mount -o minorversion=1,sec=krb5 vs1-d2.androsad.fake:/nfs4krb5 /mnt

Note GSSD creates and finds the KEYRING machine credential cache:

handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clntb)
handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clntb)
process_krb5_upcall: service is '<null>'
Full hostname for 'vs1-d2.androsad.fake' is 'vs1-d2.androsad.fake'
Full hostname for 'fedora-64-2.androsad.fake' is 'fedora-64-2.androsad.fake'
No key table entry found for FEDORA-64-2.ANDROSAD.FAKE$@ANDROSAD.FAKE while getting keytab entry for 'FEDORA-64-2.ANDROSAD.FAKE$@ANDROSAD.FAKE'
No key table entry found for root/fedora-64-2.androsad.fake@ANDROSAD.FAKE while getting keytab entry for 'root/fedora-64-2.androsad.fake@ANDROSAD.FAKE'
Success getting keytab entry for 'nfs/fedora-64-2.androsad.fake@ANDROSAD.FAKE'
INFO: Credentials in CC 'KEYRING:krb5ccmachine_ANDROSAD.FAKE' are good until 1354298952
INFO: Credentials in CC 'KEYRING:krb5ccmachine_ANDROSAD.FAKE' are good until 1354298952
using KEYRING:krb5ccmachine_ANDROSAD.FAKE as credentials cache for machine creds
using environment variable to select krb5 ccache KEYRING:krb5ccmachine_ANDROSAD.FAKE
creating context using fsuid 0 (save_uid 0)
creating tcp client for server vs1-d2.androsad.fake
DEBUG: port already set to 2049
creating context with server nfs@vs1-d2.androsad.fake
DEBUG: serialize_krb5_ctx: lucid version!
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
doing downcall lifetime_rec 1791
Closing 'gssd' pipe for /var/lib/nfs/rpc_pipefs/nfs/clnta
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnta
Closing 'gssd' pipe for /var/lib/nfs/rpc_pipefs/nfs/clnt9
destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt9

Here is the uid 0 keyring display from /proc

root@fedora-64-2 andros]# cat /proc/keys
05df6597 I--Q---     1   7m 3f010000     0     0 id_legacy uid:root@androsad.fake: 2
06acf7c5 I--Q---     1   7m 3f010000     0     0 id_legacy gid:root@androsad.fake: 2
085fd14d I--Q---     2 perm 1f3f0000     0 65534 keyring   _uid.0: empty
127383c6 I--Q---     1   9m 3f010000     0     0 id_legacy uid:nfs@androsad.fake: 3
25fa46e8 I--Q---     1   7m 3f010000     0     0 id_legacy gid:daemon@androsad.fake: 2
27de7437 I--Q---     1   9m 3f010000     0     0 id_legacy gid:unixgroup@androsad.fake: 3
2ebec4f3 I------     1 perm 1f030000     0     0 keyring   .dns_resolver: empty
2fd3ad40 I--Q---     1 perm 1f3f0000  1000 65534 keyring   _uid.1000: empty
322e313d I------     1 perm 1f030000     0     0 keyring   .id_resolver: 12/12
344c5dd9 I--Q---   101 perm 1f3f0000  1000  1000 keyring   _ses: 1/4
3a28e301 I--Q---     1   9m 3f010000     0     0 id_legacy uid:andros@androsad.fake: 5
3a761f99 I--Q---     1 perm 1f3f0000     0 65534 keyring   _uid_ses.0: 1/4
[root@fedora-64-2 andros]#


Here I run "nfslogin", a kinit then nfs-add-key:

andros@fedora-64-2 ~]$ kinit -c KEYRING:/krb5cc_1000
Password for andros@ANDROSAD.FAKE:
[andros@fedora-64-2 ~]$ cat /proc/keys
05c7977b I--Q---     1 perm 3b3f0000  1000  1000 user      __krb5_princ__: 35
08a57967 I--Q---     1 perm 3b3f0000  1000  1000 keyring   krb5cc_1000: empty
11909595 I--Q---     1 perm 3b3f0000  1000  1000 user      krbtgt/ANDROSAD.FAKE@ANDROSAD.FAKE: 465
2fd3ad40 I--Q---     1 perm 1f3f0000  1000 65534 keyring   _uid.1000: empty
344c5dd9 I--Q---   101 perm 1f3f0000  1000  1000 keyring   _ses: 3/4
3e12b317 I--Q---     1 perm 3b3f0000  1000  1000 keyring   /krb5cc_1000: 2/4

[andros@fedora-64-2 ~]$ /usr/local/src/nfs-keyring/nfs-add-key 1000 krb5cc_1000
uid: [1000], keyring:[krb5cc_1000]
[andros@fedora-64-2 ~]$ cat /proc/keys
05c7977b I--Q---     1 perm 3b3f0000  1000  1000 user      __krb5_princ__: 35
08a57967 I--Q---     1 perm 3b3f0000  1000  1000 keyring   krb5cc_1000: 1/4
11909595 I--Q---     1 perm 3b3f0000  1000  1000 user      krbtgt/ANDROSAD.FAKE@ANDROSAD.FAKE: 465
2fd3ad40 I--Q---     1 perm 1f3f0000  1000 65534 keyring   _uid.1000: empty
3281f83c I--Q---     1 perm 3b3b0000  1000  1000 gss-ctx   _nfs_gss_: 4
344c5dd9 I--Q---   101 perm 1f3f0000  1000  1000 keyring   _ses: 3/4
3e12b317 I--Q---     1 perm 3b3f0000  1000  1000 keyring   /krb5cc_1000: 2/4

Here I ls the mount point:

[andros@fedora-64-2 ~]$ ls /mnt
8.c     dir2          fialplease.txt  new.txt  test
9.c     expired4.txt  fial.txt        ooops.c  thisisbad
andros  fake.txt      heh.c           real     yech.txt
dir     fial1.txt     isittrue.txt    really
[andros@fedora-64-2 ~]$ cat /proc/keys
0009a221 I--Q---     1 perm 3b3f0000     0     0 user      __krb5_princ__: 61
0421323a I--Q---     1 perm 3b3f0000  1000  1000 user      __krb5_princ__: 35
0a941505 I--Q---     1 perm 3b3f0000     0     0 user      krbtgt/ANDROSAD.FAKE@ANDROSAD.FAKE: 516
0f570859 I--Q---     1 perm 3b3f0000  1000  1000 user      krbtgt/ANDROSAD.FAKE@ANDROSAD.FAKE: 465
1f7e3860 I--Q---     1 perm 3b3b0000  1000  1000 gss-ctx   _nfs_gss_: 4
30f2d34e I--Q---     1 perm 3b3f0000  1000     0 user      nfs/vs1-d2.androsad.fake@ANDROSAD.FAKE: 426
3474b7a1 I--Q---     1 perm 3b3f0000  1000  1000 keyring   krb5cc_1000: 4/4
383d58cd I--Q---     1 perm 3b3f0000     0     0 keyring   krb5ccmachine_ANDROSAD.FAKE: 3/4
3a17c360 I--Q---   101 perm 1f3f0000  1000  1000 keyring   _ses: 3/4
3f8e77d2 I--Q---     1 perm 3b3f0000     0     0 user      nfs/vs1-d2.androsad.fake@ANDROSAD.FAKE: 476
3fa78549 I--Q---     1 perm 1f3f0000  1000 65534 keyring   _uid.1000: empty


Here I kdestroy which also destroys the gss_context thus the immediate return of permission denied when trying to access the mount point:
Note that the keys are all gone including the gss-ctx key.

[andros@fedora-64-2 ~]$ kdestroy -c KEYRING:krb5cc_1000
[andros@fedora-64-2 ~]$ ls /mnt
ls: cannot access /mnt: Permission denied

[andros@fedora-64-2 ~]$ cat /proc/keys
0009a221 I--Q---     1 perm 3b3f0000     0     0 user      __krb5_princ__: 61
05a48686 I--Q---     1 perm 3b3f0000     0     0 keyring   krb5cc_1000: empty
0a941505 I--Q---     1 perm 3b3f0000     0     0 user      krbtgt/ANDROSAD.FAKE@ANDROSAD.FAKE: 516
383d58cd I--Q---     1 perm 3b3f0000     0     0 keyring   krb5ccmachine_ANDROSAD.FAKE: 3/4
3a17c360 I--Q---   101 perm 1f3f0000  1000  1000 keyring   _ses: 3/4
3f8e77d2 I--Q---     1 perm 3b3f0000     0     0 user      nfs/vs1-d2.androsad.fake@ANDROSAD.FAKE: 476
3fa78549 I--Q---     1 perm 1f3f0000  1000 65534 keyring   _uid.1000: empty
[andros@fedora-64-2 ~]$ kk


Andy Adamson (1):
  SUNRPC: new keyring key_type for gss context destruction at kdestroy

 net/sunrpc/auth_gss/auth_gss.c |   85 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 85 insertions(+), 0 deletions(-)

-- 
1.7.7.6

