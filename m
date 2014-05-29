Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f174.google.com ([209.85.128.174]:35630 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756140AbaE2QiU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 12:38:20 -0400
Received: by mail-ve0-f174.google.com with SMTP id jw12so680767veb.5
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2014 09:38:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140529164521.02324559@notabene.brown>
References: <20140529164521.02324559@notabene.brown>
Date: Thu, 29 May 2014 12:38:19 -0400
Message-ID: <CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
Subject: Re: Live lock in silly-rename.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies Neil. Resending due to gmail defaulting to html formatting
which gets rejected by vger.kernel.org...

On Thu, May 29, 2014 at 2:45 AM, NeilBrown <neilb@suse.de> wrote:
>
> The program below (provided by a customer) demonstrates a livelock that can
> trigger in NFS.
>
> "/mnt" should be an NFSv4 mount from a server which will hand out READ
> delegations (e.g. the Linux NFS server) and should contain a subdirectory
> "/mnt/data".
>
> The program forks off some worker threads which poll a particular file in
> that directory until it disappears.  Then each worker will exit.
> The main program waits a few seconds and then unlinks the file.
>
> The number of threads can be set with the first arg (4 is good). The number of
> seconds with the second.  Both have useful defaults.
>
> The unlink should happen promptly and then all the workers should  exit.  But
> they don't.
>
> What happens is that between when the "unlink" returns the delegation that it
> will inevitably have due to all those "open"s, and when it performs the
> required silly-rename (because some thread will have the file open), some
> other thread opens the file and gets a delegation.
> So the NFSv4 RENAME returns NFS4ERR_DELAY while it tries to reclaim the
> delegation.  15 seconds later the rename will be retried, but there will still
> (or again) be an active delegation.  So the pattern repeats indefinitely.
> All this time the i_mutex on the directory and file are held so "ls" on the
> directory will also hang.

Why would the server hand out another delegation just moments after it
recalled the last one? That sounds like a nasty server bug.

You can invent variants of this problem with a second client trying to
open() the file while the first one is trying to unlink(), where the
i_mutex hack will not suffice to prevent client 2 from getting the
delegation back.

> As an interesting twist, if you remove the file on the server, the main
> process will duly notice when it next tries to rename it, and so will exit.
> The clients will continue to successfully open and close the file, even
> though "ls -l" shows that it doesn't exist.
> If you then rm the file on the client, it will tell you that it doesn't
> exist, and the workers will suddenly notice that too.
>
> I haven't really looked into the cause of this second issue, but I can work
> around the original problem with the patch below.  It effectively serialised
> 'open' with 'unlink' (and with anything else that grabs the file's mutex).
>
> I think some sort of serialisation is needed.  I don't know whether i_mutex
> is suitable or if we should find (or make) some other locks.
>
> Thoughts?
>
> Thanks,
> NeilBrown
>
> Patch:
>
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 8de3407e0360..96108f88d3f9 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -33,6 +33,10 @@ nfs4_file_open(struct inode *inode, struct file *filp)
>
>         dprintk("NFS: open file(%pd2)\n", dentry);
>
> +       // hack - if being unlinked, pause for it to complete
> +       mutex_lock(&inode->i_mutex);
> +       mutex_unlock(&inode->i_mutex);
> +
>         if ((openflags & O_ACCMODE) == 3)
>                 openflags--;
>
>
>
> Program:
> #include <stdio.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <errno.h>
>
>
> // nfsv4 mount point /mnt
> const char check[] = "/mnt/data/checkTST";
> const char data[] = "/mnt/data/dummy.data";
>
> int num_client = 4;
> int wait_sec   = 3;
>
> // call open/close in endless loop until open fails
> void client (void)
> {
>     for (;;)
>     {
>         int f = open (check, O_RDONLY);
>
>         if (f == -1)
>         {
>             printf ("client: done\n");
>             _exit(0);
>         }
>         close (f);
>     }
> }
>
> int main (int argc, char **argv)
> {
>     int i, fd;
>     FILE *f_dummy;
>
>     if (argc > 1)
>         num_client = atoi (argv[1]);
>
>     if (argc > 2)
>         wait_sec = atoi (argv[2]);
>
>     fd = open (check, O_RDWR|O_CREAT, S_IRWXU);
>
>     if (fd == -1)
>     {
>         perror ("open failed:\n");
>         _exit (1);
>     }
>
>     close (fd);
>
>     for (i=0; i<num_client; i++)
>     {
>         // fork childs to poll the 'checkTST' file
>         pid_t p = fork ();
>         if (p==0)
>             client();
>         else if (p==-1)
>         {
>             perror ("fork failed");
>             _exit (1);
>         }
>     }
>
>       // parent process
>       // - wait a few seconds and unlink 'checkTST' file
>       // - all childs are polling the 'checkTST' and should
>       //   end now
>       sleep (wait_sec);
>       unlink (check);
>       printf ("server: done\n");
> }



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
