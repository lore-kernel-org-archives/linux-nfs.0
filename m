Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33812 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbeDCRX0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2018 13:23:26 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Daniel =?utf-8?Q?P=2EBerrang?= =?utf-8?Q?=C3=A9?=
        <berrange@redhat.com>, Kate Stewart <kstewart@linuxfoundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Philippe Ombredanne <pombredanne@nexb.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "open list\:NFS\, SUNRPC\, AND..." <linux-nfs@vger.kernel.org>
References: <20180317142520.30520-1-jlayton@kernel.org>
        <20180317165859.26200-1-jlayton@kernel.org>
        <87bmfgvg8w.fsf@xmission.com> <871sgcvfh7.fsf@xmission.com>
        <1522673814.4914.36.camel@kernel.org>
Date: Tue, 03 Apr 2018 12:22:08 -0500
In-Reply-To: <1522673814.4914.36.camel@kernel.org> (Jeff Layton's message of
        "Mon, 02 Apr 2018 08:56:54 -0400")
Message-ID: <87r2nwqk73.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2] locks: change POSIX lock ownership on execve when files_struct is displaced
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@kernel.org> writes:

> On Thu, 2018-03-22 at 00:36 -0500, Eric W. Biederman wrote:
>> ebiederm@xmission.com (Eric W. Biederman) writes:
>> 
>> > Jeff Layton <jlayton@kernel.org> writes:
>> > 
>> > > From: Jeff Layton <jlayton@redhat.com>
>> > > 
>> > > POSIX mandates that open fds and their associated file locks should be
>> > > preserved across an execve. This works, unless the process is
>> > > multithreaded at the time that execve is called.
>> > Would this perhaps work better if we moved unshare_files to after or
>> > inside of de_thread.  That would remove any cases where fd->count is > 1
>> > simply because you are multi-threaded.  It would only leave the strange
>> > cases where files struct is shared between different processes.
>> 
>> The fact we have a problem here appears to be a regression caused by:
>> fd8328be874f ("[PATCH] sanitize handling of shared descriptor tables in
>> failing execve()")
>> 
>> So I really think we are calling unshare_files in the wrong location.
>> 
>> We could perhaps keep the benefit of being able to fail exec cleanly
>> if we freeze the threads and then only unshare if the count of threads
>> differs from the fd->count.  I don't know if it is worth it.
>> 
>> Eric
>> 
>
> Yeah, that's a possibility. If you can freeze the other threads, and
> ensure that they don't execute before they are killed, then in almost
> all cases, unshare_files would be a noop.

The only problem is the handlful of places like proc/fd and binder that
call get_files_struct then put_files_struct.  So the count on the files
struct may be artificually elevated.

Which actually means there is a race and if someone opens files in
/proc/<execing pid>/fd at the right moment unshare_files may even
unshare_files for a single threaded process.

> Also, I have spotted a potential problem with this patch too:
>
> If this situation occurs on NFS, then the state handling code is likely
> to get very confused. It uses the fl_owner as the key to the
> lock_stateid.
>
> After you execve, the all the locks will still be present but you won't
> be able to find them by fl_owner anymore. I imagine they'll just hang
> out until the client expires.
>
> David Howells suggested: "you could allocate a 1-byte lock cookie and
> point to that from fdtable, then pass that cookie over exec"
>
> I'm not sure about that implementation (maybe consider using ida?), but
> an opaque fl_owner cookie for posix locks might be the way to go. It
> would mean growing struct fdtable however.

It looks like struct file_table has 32 bytes of padding on any
architecture with 64byte cache lines.  So with care I believe you can
avoid growing struct file_table.

The cookie would needs to be a pointer because it is stored in the same
space as other pointers so it needs to disambiguate between pointers.
Plus the cookie would need a reference count, as multiple instances
of struct file_table could point to it.

Thinking about it I am not a fan of the cooking solution or of the
moving the owner solution because when two processes share a file_table
it changes which process owns the locks from the fdtable after exec.
Currently it is the process that doesn't exec.


Separating counting down for task_structs and users of get_files_struct
would seem to be a straight forward solution to the possibility of
overcounts.


Ignoring backwards compatibily.  I would argue that the proper solution
is to remove unshare_files completely.  Do what we do with the fs_struct
in check_unsafe_exec and simply set LSM_UNSAFE_UNSHARE if we are sharing
the files struct with anything other than a thread.

That said we do have backwards compatibility to worry about, and there
is the weirdness of a process which does not exec having file
descriptors close in their file table.  So I do think it is best
to unshare the file descriptor table.


The only file descriptor I have find that in the exec code path is the
file descriptor that is passed into exec.  So I don't think races with
file descriptors are a reason to be doing unshare_files early.

The only race I can think of that might be worth considering is what
happens if one thread calls clone(CLONE_FILES) while we are calling
exec.  The clone(CLONE_FS) case prevents that race by returning
-EAGAIN from clone if fs->in_exec is set.  So there is a known
path for handling that race.



I think the way I would fix the issue is:
- Use a different counter on file_table for get_files_struct than for
  threads.  Solving the miscount issue.
- Protect the thread_counter in struct file_table with files_lock.
- Add an in_exec field in struct file_table.
- Cause clone(CLONE_FILES) to fail if in_exec is set.
- Write the code to see if file_table is shared beyond a single process
  in a race free way.
- Set in_exec if the file_table is not shared between processes.
- Unshare the fd table if the fd table is shared between processes.


To help understand what is going on and why I dug through the history
and found a couple of key commits that pretty much say when and why
things are happening.  Some of them come from tglx's history tree so you
need to look there for the earlier commits.

commit 04e9bcb4d10643da38b434492fb75dd10e0ceba8
Author: Andrew Morton <akpm@osdl.org>
Date:   Mon Dec 29 05:41:27 2003 -0800

    [PATCH] use new unshare_files helper
    
    From: Chris Wright <chrisw@osdl.org>
    
    Use unshare_files during binary loading to eliminate potential leak of
    the binary's fd installed during execve().  As is, this breaks
    binfmt_som.c

<--- Adds unshare_files in flush_old_exec --->

ommit 02c541ec8ffa92178a93e74f1c77963d73772454
Author: Andrew Morton <akpm@osdl.org>
Date:   Mon Dec 29 05:41:43 2003 -0800

    [PATCH] use new steal_locks helper
    
    From: Chris Wright <chrisw@osdl.org>
    
    Use the new steal_locks helper to steal the locks from the old files struct
    left from unshare_files() when the new unshared struct files gets used.

<--- Adds a helper like you are suggesting to add now --->


commit c89681ed7d0e4a61d35bdc12c06c6733b718b2cb
Author: Miklos Szeredi <miklos@szeredi.hu>
Date:   Thu Jun 22 14:47:22 2006 -0700

    [PATCH] remove steal_locks()
    
    This patch removes the steal_locks() function.
    
    steal_locks() doesn't work correctly with any filesystem that does it's own
    lock management, including NFS, CIFS, etc.
    
    In addition it has weird semantics on local filesystems in case tasks
    sharing file-descriptor tables are doing POSIX locking operations in
    parallel to execve().
    
    The steal_locks() function has an effect on applications doing:
    
    clone(CLONE_FILES)
      /* in child */
      lock
      execve
      lock
    
    POSIX locks acquired before execve (by "child", "parent" or any further
    task sharing files_struct) will after the execve be owned exclusively by
    "child".
    
    According to Chris Wright some LSB/LTP kind of suite triggers without the
    stealing behavior, but there's no known real-world application that would
    also fail.
    
    Apps using NPTL are not affected, since all other threads are killed before
    execve.
    
    Apps using LinuxThreads are only affected if they
    
      - have multiple threads during exec (LinuxThreads doesn't kill other
        threads, the app may do it with pthread_kill_other_threads_np())
      - rely on POSIX locks being inherited across exec
    
    Both conditions are documented, but not their interaction.
    
    Apps using clone() natively are affected if they
    
      - use clone(CLONE_FILES)
      - rely on POSIX locks being inherited across exec
    
    The above scenarios are unlikely, but possible.
    
    If the patch is vetoed, there's a plan B, that involves mostly keeping the
    weird stealing semantics, but changing the way lock ownership is handled so
    that network and local filesystems work consistently.
    
    That would add more complexity though, so this solution seems to be
    preferred by most people.
    
    Signed-off-by: Miklos Szeredi <miklos@szeredi.hu>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Cc: Matthew Wilcox <willy@debian.org>
    Cc: Chris Wright <chrisw@sous-sol.org>
    Cc: Christoph Hellwig <hch@lst.de>
    Cc: Steven French <sfrench@us.ibm.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

<--- This removes code that looks essentially like the code in your
     patch for the reasons you have mentioned. --->

commit fd8328be874f4190a811c58cd4778ec2c74d2c05
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Tue Apr 22 05:11:59 2008 -0400

    [PATCH] sanitize handling of shared descriptor tables in failing execve()
    
    * unshare_files() can fail; doing it after irreversible actions is wrong
      and de_thread() is certainly irreversible.
    * since we do it unconditionally anyway, we might as well do it in do_execve()
      and save ourselves the PITA in binfmt handlers, etc.
    * while we are at it, binfmt_som actually leaked files_struct on failure.
    
    As a side benefit, unshare_files(), put_files_struct() and reset_files_struct()
    become unexported.
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

<--- This change guaranteed that unshare_files will fail for thread
     programs which ultimately got the conversation started again --->


commit e7b9b550f53e81ea38e71d322d6f95730df058a2
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Sun Mar 29 16:31:16 2009 -0400

    Don't mess with descriptor table in load_elf_binary()
    
    ... since we don't tell anyone which descriptor does the file get.
    We used to, but only in case of ELF binary with a.out loader and
    that stuff has been gone for a while.
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>


commit d9e66c7296f3a39f6ac847f11ada8ddf10a4f8b1
Author: Al Viro <viro@zeniv.linux.org.uk>
Date:   Sun Mar 29 16:34:56 2009 -0400

    Don't crap into descriptor table in binfmt_som
    
    Same story as in binfmt_elf, except that in binfmt_som we
    actually forget to close the sucker.
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>


<--- At this point there don't appear any other file descriptors to
     worry about --->

commit 35e88d5c22e1916c819b5a8756aed2f09a4aba18
Author: Helge Deller <deller@gmx.de>
Date:   Tue Feb 17 15:41:51 2015 +0100

    fs/binfmt_som: Drop kernel support for HP-UX SOM binaries
    
    The parisc arch has been the only user of HP-UX SOM binaries.
    
    Support for HP-UX executables was never finished and since we now drop support
    for the HP-UX compat layer anyway, it does not makes sense to keep the
    BINFMT_SOM support.
    
    Cc: linux-fsdevel@vger.kernel.org
    Cc: linux-parisc@vger.kernel.org
    Signed-off-by: Helge Deller <deller@gmx.de>

<--- The original motivation for unshare_files has been removed --->


Eric
