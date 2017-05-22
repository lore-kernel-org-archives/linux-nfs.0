Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35383 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758262AbdEVRMI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 13:12:08 -0400
Received: by mail-wm0-f46.google.com with SMTP id b84so1813490wmh.0
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 10:12:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
From: Jessica Frazelle <me@jessfraz.com>
Date: Mon, 22 May 2017 18:11:46 +0100
Message-ID: <CAEk6tEyjk4=rHfsJUZ7dYPpdSa-=QX6QAm8ni8-ySpHmjUMwTg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
To: David Howells <dhowells@redhat.com>
Cc: trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        ebiederm@xmission.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is interesting...

Adding a container object seems a bit odd to me because there are so
many different ways to make containers, aka not all namespaces are
always used as well as not all cgroups, various LSM objects sometimes
apply, mounts blah blah blah. The OCI spec was made to cover all these
things so why a kernel object? I don't exactly see a future where the
container runtimes convert to this unless it covers all the same mods
as the mods in the OCI spec, not saying it needs to abide by the spec,
just saying it should allow all the same things. Which really just
seems, imo, like a pain for the kernel to have to maintain.

On Mon, May 22, 2017 at 5:22 PM, David Howells <dhowells@redhat.com> wrote:
>
> Here are a set of patches to define a container object for the kernel and
> to provide some methods to create and manipulate them.
>
> The reason I think this is necessary is that the kernel has no idea how to
> direct upcalls to what userspace considers to be a container - current
> Linux practice appears to make a "container" just an arbitrarily chosen
> junction of namespaces, control groups and files, which may be changed
> individually within the "container".
>
> The kernel upcall mechanism then needs to decide which set of namespaces,
> etc., it must exec the appropriate upcall program.  Examples of this
> include:
>
>  (1) The DNS resolver.  The DNS cache in the kernel should probably be
>      per-network namespace, but in userspace the program, its libraries and
>      its config data are associated with a mount tree and a user namespace
>      and it gets run in a particular pid namespace.
>
>  (2) NFS ID mapper.  The NFS ID mapping cache should also probably be
>      per-network namespace.
>
>  (3) nfsdcltrack.  A way for NFSD to access stable storage for tracking
>      of persistent state.  Again, network-namespace dependent, but also
>      perhaps mount-namespace dependent.
>
>  (4) General request-key upcalls.  Not particularly namespace dependent,
>      apart from keyrings being somewhat governed by the user namespace and
>      the upcall being configured by the mount namespace.

Can't these all become namespace-aware without adding the notion of a
"container" to the kernel.

>
> These patches are built on top of the mount context patchset so that
> namespaces can be properly propagated over submounts/automounts.
>
> These patches implement a container object that holds the following things:
>
>  (1) Namespaces.
>
>  (2) A root directory.
>
>  (3) A set of processes, including a designated 'init' process.
>
>  (4) The creator's credentials, including ownership.
>
>  (5) A place to hang security for the container, allowing policies to be
>      set per-container.
>
> I also want to add:
>
>  (6) Control groups.
>
>  (7) A per-container keyring that can be added to from outside of the
>      container, even once the container is live, for the provision of
>      filesystem authentication/encryption keys in advance of the container
>      being started.
>
> You can get a list of containers by examining /proc/containers - but I'm
> not sure how much value this gets you.  Note that the container in which
> you are running is called "<current>" and you can only see other containers
> that were started from within yours.  Containers are therefore effectively
> hierarchical and an init_container is set up when the system boots.
>
>
> Some management operations are provided:
>
>  (1) int fd = container_create(const char *name, unsigned int flags);
>
>      Create a container of the given name and return a handle to it as a
>      file descriptor.  flags indicates what namespaces should be inherited
>      from the caller and what should be replaced new.  It is possible to
>      set up a container with a null root filesystem that can be mounted
>      later.
>
>  (2) int fsfd = fsopen(const char *fsname, int container_fd,
>                        unsigned int flags);
>
>      Prepare a mount context inside the container.  This uses all the
>      containers namespaces instead of the caller's.
>
>  (3) fsmount(int fsfd, int dfd, const char *path, unsigned int at_flags,
>              unsigned int flags);
>
>      Mount a prepared superblock.  dfd can be given container_fd to use the
>      container to which it refers as the root of the pathwalk.
>
>      If path is "/" and at_flags is AT_FSMOUNT_CONTAINER_ROOT, then this
>      will attempt to mount the root of the container and create a mount
>      namespace for it.  The container must've been created with
>      CONTAINER_NEW_EMPTY_FS_NS.
>
>  (4) pid_t pid = fork_into_container(int container_fd);
>
>      Create the init process in a container.  The process uses that
>      container's namespaces instead of the caller's.
>
>  (5) int sfd = container_socket(int container_fd,
>                                 int domain, int type, int protocol);
>
>      Create a socket inside a container.  The socket gets the container's
>      namespaces.  This allows netlink operations to be called within that
>      container to set it up from outside (at least in theory).
>
>  (6) mkdirat(int dfd, ...);
>      mknodat(int dfd, ...);
>      openat(int dfd, ...);
>
>      Supplying a container fd as dfd makes the pathwalk happen relative to
>      the root of the container.  Note that the path must be *relative*.
>
> And some need to be/could be added:
>
>  (7) Directly set a container's namespaces to allow cross-container
>      sharing.
>
>  (8) Adjust the control group membership of a container.
>
>  (9) Add a key inside a container keyring.
>
> (10) Kill/suspend/freeze/reboot container, both from inside and out.
>
> (11) Set container's root dir.
>
> (12) Set the container's security policy.
>
> (13) Allow overlayfs to access filesystems outside of the container in
>      which it is being created.
>
>
> Kernel upcalls are invoked in the root of the container that incurs them
> rather than in the init namespace context.  There's still some awkwardness
> here if you, say, share a network namespace between containers.  Either the
> upcall binaries and configuration must be duplicated between sharing
> containers or a container must be elected as the one in which such upcalls
> will be done.
>
>
> Some further thoughts:
>
>  (*) Should there be an AT_IN_CONTAINER flag to provide to syscalls that
>      take a container in lieu of AT_FDCWD or a directory fd?  The problem
>      is that such as mkdirat() and openat() don't have an at_flags
>      argument.
>
>  (*) Should there be a container hierarchy at all?  It seems that this is
>      only really necessary for /proc/containers.  Do we want to allow
>      containers-within-containers?
>
>  (*) Should each container automatically have its own pid namespace such
>      that its 'init' process always appears as pid 1?
>
>  (*) Does this allow kernel upcalls to be accounted against the correct
>      control group?
>
>  (*) Should each container have a 'list' of accessible device numbers such
>      that certain device files can be made usable within a container?  And
>      can devtmpfs/udev be made to show the correct file set for each
>      container?
>
>
> The patches can be found here also:
>
>         http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=container
>
> Note that this is dependent on the mount-context branch.
>
> David
> ---
> David Howells (9):
>       containers: Rename linux/container.h to linux/container_dev.h
>       Implement containers as kernel objects
>       Provide /proc/containers
>       Allow processes to be forked and upcalled into a container
>       Open a socket inside a container
>       Allow fs syscall dfd arguments to take a container fd
>       Make fsopen() able to initiate mounting into a container
>       Honour CONTAINER_NEW_EMPTY_FS_NS
>       Sample program for driving container objects
>
>
>  arch/x86/entry/syscalls/syscall_32.tbl |    3
>  arch/x86/entry/syscalls/syscall_64.tbl |    3
>  drivers/acpi/container.c               |    2
>  drivers/base/container.c               |    2
>  fs/fsopen.c                            |   33 +-
>  fs/libfs.c                             |    3
>  fs/namei.c                             |   52 ++-
>  fs/namespace.c                         |  108 +++++-
>  fs/nfs/namespace.c                     |    2
>  fs/nfs/nfs4namespace.c                 |    4
>  fs/proc/root.c                         |   13 +
>  fs/sb_config.c                         |   29 +-
>  include/linux/container.h              |   91 ++++-
>  include/linux/container_dev.h          |   25 +
>  include/linux/cred.h                   |    3
>  include/linux/init_task.h              |    4
>  include/linux/kmod.h                   |    1
>  include/linux/lsm_hooks.h              |   25 +
>  include/linux/mount.h                  |    5
>  include/linux/nsproxy.h                |    7
>  include/linux/pid.h                    |    5
>  include/linux/proc_ns.h                |    3
>  include/linux/sb_config.h              |    5
>  include/linux/sched.h                  |    3
>  include/linux/sched/task.h             |    4
>  include/linux/security.h               |   20 +
>  include/linux/syscalls.h               |    6
>  include/uapi/linux/container.h         |   28 ++
>  include/uapi/linux/fcntl.h             |    2
>  include/uapi/linux/magic.h             |    1
>  init/Kconfig                           |    7
>  init/main.c                            |    4
>  kernel/Makefile                        |    2
>  kernel/container.c                     |  576 ++++++++++++++++++++++++++++++++
>  kernel/cred.c                          |   45 ++-
>  kernel/exit.c                          |    1
>  kernel/fork.c                          |  117 ++++++-
>  kernel/kmod.c                          |   13 +
>  kernel/kthread.c                       |    3
>  kernel/namespaces.h                    |   15 +
>  kernel/nsproxy.c                       |   34 +-
>  kernel/pid.c                           |    4
>  kernel/sys_ni.c                        |    5
>  net/socket.c                           |   37 ++
>  samples/containers/test-container.c    |  162 +++++++++
>  security/security.c                    |   18 +
>  security/selinux/hooks.c               |    5
>  47 files changed, 1408 insertions(+), 132 deletions(-)
>  create mode 100644 include/linux/container_dev.h
>  create mode 100644 include/uapi/linux/container.h
>  create mode 100644 kernel/container.c
>  create mode 100644 kernel/namespaces.h
>  create mode 100644 samples/containers/test-container.c
>
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 


Jessie Frazelle
4096R / D4C4 DD60 0D66 F65A 8EFC  511E 18F3 685C 0022 BFF3
pgp.mit.edu
