Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A472C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:07:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DFC1621927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:07:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727264AbfBOQHT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:07:19 -0500
Received: from mx1.redhat.com ([209.132.183.28]:37702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726213AbfBOQHS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:07:18 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E48603DDB6;
        Fri, 15 Feb 2019 16:07:17 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7A53960BE2;
        Fri, 15 Feb 2019 16:07:15 +0000 (UTC)
Subject: [RFC PATCH 00/27] Containers and using authenticated filesystems
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:07:14 +0000
Message-ID: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 15 Feb 2019 16:07:18 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Here's a collection of patches that containerises the kernel keys and makes
it possible to separate keys by namespace.  This can be extended to any
filesystem that uses request_key() to obtain the pertinent authentication
token on entry to VFS or socket methods.

I have this working with AFS and AF_RXRPC so far, but it could be extended
to other filesystems, such as NFS and CIFS.

The following changes are made:

 (1) Add optional namespace tags to a key's index_key.  This allows the
     following:

     (a) Automatic invalidation of all keys with that tag when the
     	 namespace is removed.

     (b) Mixing of keys with the same description, but different areas of
     	 operation within a keyring.

     (c) Sharing of cache keyrings, such as the DNS lookup cache.

     (d) Diversion of upcalls based on namespace criteria.

 (2) Provide each network namespace with a tag that can be used with (1).
     This is used by the DNS query, rxrpc, nfs idmapper keys.

     [!] Note that it might still be better to move these keyrings into the
     	 network namespace.

 (3) Provide key ACLs.  These allow:

     (a) The permissions can be split more finely, in particular separating
     	 out Invalidate and Join.

     (b) Permits to be granted to non-standard subjects.  So, for instance,
     	 Search permission could be granted to a container object, allowing
     	 a search of the container keyring by a denizen of the container to
     	 find a key that they can't otherwise see.

 (4) Provide a kernel container object.  Currently, this is created with a
     system call and passed flags that indicate the namespaces to be
     inherited or replaced.  It might be better to actually use something
     like fsconfig() to configure the container by setting key=val type
     options.

     The kernel container object provides the following facilities:

     (a) request_key upcall interception.  The manager of a container can
     	 intercept requests made inside the container and, using a series
     	 of filters, can cause the authkeys to be placed into keyrings that
     	 serve as queues for one or more upcall processing programs.  These
     	 upcall programs use key notifications to monitor those keyrings.

     (b) Per-container keyring.  A keyring can be attached to the container
     	 such that this is searched by a request_key() performed by a
     	 denizen of the container after searching the thread, process and
     	 session keyrings.  The keyring and the keys contained therein must
     	 be granted Search for that container.

	 This allows:

 	 (i) Authenticated filesystems to be used transparently inside of
	     the container without any cooperation from the occupant
	     thereof.  All the key maintenance can be done by the manager.

         (ii) Keys to be made available to the denizens of a container (by
             granting extra permissions to the container subject).

     (c) Per-container ID that can be used in audit messages.

     (d) Container object creation gives the manager a file descriptor that
     	 can:

	 (i) Be passed to a dirfd parameter to a VFS syscall, such as
     	     mkdirat(), allowing an operation to be done inside the
     	     container.

         (ii) Be passed to fsopen()/fsconfig() to indicate that the target
             filesystem is going to be created inside a container, in that
             container's namespaces.

         (iii) Be passed to the move_mount() syscall as a destination for
             setting the root filesystem inside a new mount namespace made
             upon container creation.

     (e) The ability to configure the container with namespaces or
     	 whatever, and then fork a process into that container to 'boot'
     	 it.


Three sample programs are provided:

 (1) test-container.  This:

	- Creates a kernel container with a blank mount ns.
	- Creates its root mount and moves it to the container root.
	- Mounts /proc therein.
	- Creates a keyring called "_container"
	  - Sets that as the container keyring.
	  - Grants Search permission to the container on that keyring.
	  - Removes owner permission on that keyring.
	- Creates a sample user key "foobar" in the container keyring.
	  - Grants various permissions to the container on that key.
	- Creates a keyring called "upcall"
	  - Intercepts "user" key upcalls from the container to there.
	- Forks a process into the container
	  - Prints the container keyring ID if it can
	  - Exec's bash.

     This program expects to be given the device name for a partition it
     can mount as the root and expects it to contain things like /etc,
     /bin, /sbin, /lib, /usr containing programs that can be run and /proc
     to mount procfs upon.  E.g.:

	./test-container /dev/sda3

 (2) test-upcall.  This is a service program that monitors the "upcall"
     keyring created by test-container for authkeys appearing, which it
     then hands off to /sbin/request-key.  This:

	- Opens /dev/watch_queue.
	  - Sets the size to 1 page.
	  - Sets a filter to watch for "Link creation" key events.
	  - Sets a watch on the upcall keyring.
	- Polls the watch queue for events
	- When an event comes in:
	  - Gets the authkey ID from the event buffer.
	  - Queries the authkey.
	  - Forks of a handler which:
	    - Moves the authkey to its thread keyring
	    - Sets up a new session keyring with the authkey in it.
	    - Execs /sbin/request-key.

     This can be run in a shell that shares the session keyring with
     test-container, from which it will find the upcall keyring.
     Alternatively, the keyring ID can be provided on the command line:

	./test-upcall [<upcall-keyring>]

     It can be triggered from inside of the container with something like:

	keyctl request2 user debug:e a @s

     and something like:

	ptrs h=4 t=2 m=2000003
	NOTIFY[00000004-00000002] ty=0003 sy=0002 i=01000010
	KEY 78543393 change=2 aux=141053003
	Authentication key 141053003
	- create 779280685
	- uid=0 gid=0
	- rings=0,0,798528519
	- callout='a'
	RQDebug keyid: 779280685
	RQDebug desc: debug:e
	RQDebug callout: a
	RQDebug session keyring: 798528519

     will appear on stdout/stderr from it and /sbin/request-key.

 (3) test-cont-grant.  This is a program to make the nominated key
     available to a container's denizens.  It:

	- Grants search permission to the nominated key.
	- Links the nominated key into the container keyring.

     It can be run from outside of the keyring like so:

	./test-cont-grant <key> [<container-keyring>]

     If the keyring isn't given, it will look for one called "_container"
     in the session keyring where test-container is expected to have placed
     it.

     With kAFS, it can be used like follows:

	kinit dhowells@REDHAT.COM
	kafs-aklog redhat.com

     which would log into kerberos and then get a key for accessing an AFS
     cell called "redhat.com".  This can be seen in the session keyring by
     calling "keyctl show":

	 120378984 --alswrv      0     0  keyring: _ses
	 474754113 ---lswrv      0 65534   \_ keyring: _uid.0
	  64049961 --alswrv      0     0   \_ rxrpc: afs@redhat.com
	  78543393 --alswrv      0     0   \_ keyring: upcall
	 661655334 --alswrv      0     0   \_ keyring: _container
	 639103010 --alswrv      0     0       \_ user: foobar

     Then doing:

	./test-cont-grant 64049961

     will result in:

	 120378984 --alswrv      0     0  keyring: _ses
	 474754113 ---lswrv      0 65534   \_ keyring: _uid.0
	  64049961 --alswrv      0     0   \_ rxrpc: afs@procyon.org.uk
	  78543393 --alswrv      0     0   \_ keyring: upcall
	 661655334 --alswrv      0     0   \_ keyring: _container
	 639103010 --alswrv      0     0       \_ user: foobar
	  64049961 --alswrv      0     0       \_ rxrpc: afs@procyon.org.uk

     Inside the container, the cell could be mounted:

	mount -t afs "%redhat.com:root.cell" /mnt

     and then operations in /mnt will be done using the token that has been
     made available.  However, this can be overridden locally inside the
     container by doing kinit and kafs-aklog there with a different user.

     More to the point, the container manager could mount the container's
     rootfs, say, over authenticated AFS and then attach the token to the
     container and mount the rootfs into the container and the container's
     inhabitant need not have any means to gain a kerberos login.

     [?] I do wonder if the possibility to use container key searches for
     	 direct mounts should be controlled by a mount option, say:

		fsconfig(fsfd, FSCONFIG_SET_CONTAINER, NULL, NULL, cfd);

         where you have to have the container handle available.

     [!] Note that test-cont-grant picks the container by name and does not
     	 require the container handle when setting the key ACL - but the
     	 name must come from the set of children of the current container.


The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=container

Note that this is dependent on the mount-api-viro, fsinfo, notifications
and keys-namespace branches.

David
---
David Howells (27):
      containers: Rename linux/container.h to linux/container_dev.h
      containers: Implement containers as kernel objects
      containers: Provide /proc/containers
      containers: Allow a process to be forked into a container
      containers: Open a socket inside a container
      containers, vfs: Allow syscall dirfd arguments to take a container fd
      containers: Make fsopen() able to create a superblock in a container
      containers, vfs: Honour CONTAINER_NEW_EMPTY_FS_NS
      vfs: Allow mounting to other namespaces
      containers: Provide fs_context op for container setting
      containers: Sample program for driving container objects
      containers: Allow a daemon to intercept request_key upcalls in a container
      keys: Provide a keyctl to query a request_key authentication key
      keys: Break bits out of key_unlink()
      keys: Make __key_link_begin() handle lockdep nesting
      keys: Grant Link permission to possessers of request_key auth keys
      keys: Add a keyctl to move a key between keyrings
      keys: Find the least-recently used unseen key in a keyring.
      containers: Sample: request_key upcall handling
      container, keys: Add a container keyring
      keys: Fix request_key() lack of Link perm check on found key
      KEYS: Replace uid/gid/perm permissions checking with an ACL
      KEYS: Provide KEYCTL_GRANT_PERMISSION
      keys: Allow a container to be specified as a subject in a key's ACL
      keys: Provide a way to ask for the container keyring
      keys: Allow containers to be included in key ACLs by name
      containers: Sample to grant access to a key in a container


 arch/x86/entry/syscalls/syscall_32.tbl             |    3 
 arch/x86/entry/syscalls/syscall_64.tbl             |    3 
 arch/x86/ia32/sys_ia32.c                           |    2 
 certs/blacklist.c                                  |    7 
 certs/system_keyring.c                             |   12 
 drivers/acpi/container.c                           |    2 
 drivers/base/container.c                           |    2 
 drivers/md/dm-crypt.c                              |    2 
 drivers/nvdimm/security.c                          |    2 
 fs/afs/security.c                                  |    2 
 fs/afs/super.c                                     |   18 +
 fs/cifs/cifs_spnego.c                              |   25 +
 fs/cifs/cifsacl.c                                  |   28 +
 fs/cifs/connect.c                                  |    4 
 fs/crypto/keyinfo.c                                |    2 
 fs/ecryptfs/ecryptfs_kernel.h                      |    2 
 fs/ecryptfs/keystore.c                             |    2 
 fs/fs_context.c                                    |   39 +
 fs/fscache/object-list.c                           |    2 
 fs/fsopen.c                                        |   54 ++
 fs/namei.c                                         |   45 +-
 fs/namespace.c                                     |  129 ++++-
 fs/nfs/nfs4idmap.c                                 |   29 +
 fs/proc/root.c                                     |   20 +
 fs/ubifs/auth.c                                    |    2 
 include/linux/container.h                          |  100 +++-
 include/linux/container_dev.h                      |   25 +
 include/linux/cred.h                               |    3 
 include/linux/fs_context.h                         |    5 
 include/linux/init_task.h                          |    1 
 include/linux/key-type.h                           |    2 
 include/linux/key.h                                |  122 +++--
 include/linux/lsm_hooks.h                          |   20 +
 include/linux/nsproxy.h                            |    7 
 include/linux/pid.h                                |    5 
 include/linux/proc_ns.h                            |    6 
 include/linux/sched.h                              |    3 
 include/linux/sched/task.h                         |    3 
 include/linux/security.h                           |   15 +
 include/linux/socket.h                             |    3 
 include/linux/syscalls.h                           |    6 
 include/uapi/linux/container.h                     |   28 +
 include/uapi/linux/keyctl.h                        |   85 +++
 include/uapi/linux/mount.h                         |    4 
 init/Kconfig                                       |    7 
 init/init_task.c                                   |    3 
 ipc/mqueue.c                                       |   10 
 kernel/Makefile                                    |    2 
 kernel/container.c                                 |  532 ++++++++++++++++++++
 kernel/cred.c                                      |   45 ++
 kernel/exit.c                                      |    1 
 kernel/fork.c                                      |  111 ++++
 kernel/namespaces.h                                |   15 +
 kernel/nsproxy.c                                   |   32 +
 kernel/pid.c                                       |    4 
 kernel/sys_ni.c                                    |    5 
 lib/digsig.c                                       |    2 
 net/ceph/ceph_common.c                             |    2 
 net/compat.c                                       |    2 
 net/dns_resolver/dns_key.c                         |   12 
 net/dns_resolver/dns_query.c                       |   15 -
 net/rxrpc/key.c                                    |   16 -
 net/socket.c                                       |   34 +
 samples/vfs/Makefile                               |   12 
 samples/vfs/test-cont-grant.c                      |   84 +++
 samples/vfs/test-container.c                       |  382 ++++++++++++++
 samples/vfs/test-upcall.c                          |  243 +++++++++
 security/integrity/digsig.c                        |   31 -
 security/integrity/digsig_asymmetric.c             |    2 
 security/integrity/evm/evm_crypto.c                |    2 
 security/integrity/ima/ima_mok.c                   |   13 
 security/integrity/integrity.h                     |    4 
 .../integrity/platform_certs/platform_keyring.c    |   13 
 security/keys/Makefile                             |    2 
 security/keys/compat.c                             |   20 +
 security/keys/container.c                          |  419 ++++++++++++++++
 security/keys/encrypted-keys/encrypted.c           |    2 
 security/keys/encrypted-keys/masterkey_trusted.c   |    2 
 security/keys/gc.c                                 |    2 
 security/keys/internal.h                           |   34 +
 security/keys/key.c                                |   35 -
 security/keys/keyctl.c                             |  176 +++++--
 security/keys/keyring.c                            |  198 ++++++-
 security/keys/permission.c                         |  446 +++++++++++++++--
 security/keys/persistent.c                         |   27 +
 security/keys/proc.c                               |   17 -
 security/keys/process_keys.c                       |  102 +++-
 security/keys/request_key.c                        |   70 ++-
 security/keys/request_key_auth.c                   |   21 +
 security/security.c                                |   12 
 security/selinux/hooks.c                           |   16 +
 security/smack/smack_lsm.c                         |    3 
 92 files changed, 3696 insertions(+), 425 deletions(-)
 create mode 100644 include/linux/container_dev.h
 create mode 100644 include/uapi/linux/container.h
 create mode 100644 kernel/container.c
 create mode 100644 kernel/namespaces.h
 create mode 100644 samples/vfs/test-cont-grant.c
 create mode 100644 samples/vfs/test-container.c
 create mode 100644 samples/vfs/test-upcall.c
 create mode 100644 security/keys/container.c

