Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47566 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932178AbcLHTna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 14:43:30 -0500
Date: Thu, 8 Dec 2016 14:43:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Brian Cowan <brian.cowan@hcl.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: FW: File lock performance over NFSv4 degrades dramatically when
 lock contention is present.
Message-ID: <20161208194328.GA26583@fieldses.org>
References: <HK2PR0401MB157008D9798FDBF609C616EEFE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
 <HK2PR0401MB1570ACF852B10ADA56DB0059FE820@HK2PR0401MB1570.apcprd04.prod.outlook.com>
 <20161206204745.GB1203@fieldses.org>
 <HK2PR0401MB1570E4FEB293CA7CECA082D4FE840@HK2PR0401MB1570.apcprd04.prod.outlook.com>
 <20161208161926.GB23713@fieldses.org>
 <HK2PR0401MB157007F3B5C5353EED6A9E5FFE840@HK2PR0401MB1570.apcprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <HK2PR0401MB157007F3B5C5353EED6A9E5FFE840@HK2PR0401MB1570.apcprd04.prod.outlook.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2016 at 07:28:13PM +0000, Brian Cowan wrote:
> Server and client are both running the 4.9.0-rc8 kernel. 

I missed that you were only using one client.

In that case I would think the client would be able to get the same
performance as in the v3 case even without this new NFSv4.1 lock
notification: the client knows when it released a conflicting lock, so
why wouldn't it wake up any local waiters then instead of waiting for a
timeout or a server callback?

Without looking at the code.... In it's current form all it can probably
do is wake every waiter and let them race for their locks, which is
relatively cheap in the local case but might be more expensive in the
remote case--I wonder if that's the issue.  So it might be a reason to
revisit the idea of waking only the waiters we need to.  Then again if
it's a lot of complexity it may not be worth it for something already
fixed in 4.1.

Anyway, it's good news at least that the new NFSv4.1 lock notification
feature does seem to be working for you.

--b.

> 
> I confirmed the nfs support in nfsd using cat /proc/fs/nfsd/versions, and it includes 4.1 and 4.2.
> 
> What I forgot is that my automounter is forcing nfsv4 mounts. I just changed it to force 4.1 ("...vers=4,..." to "...vers=4.1,...") Funny how that little thing had a big impact...
> 
> My log lock times essentially disappeared. In my 5 minute test, the longest lock wait time was 0.2 seconds, and the next highest lock request time was .04 seconds. MUCH different.
> 
> Now that raw benchmarking seems to show improvement, it's time to see what this looks like in a longer test, and then at a higher level...
> 
> Thanks for the assist, and the pointers.
> 
> Brian 
> 
> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> Sent: Thursday, December 8, 2016 11:19 AM
> To: Brian Cowan <brian.cowan@hcl.com>
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: FW: File lock performance over NFSv4 degrades dramatically when lock contention is present.
> 
> On Thu, Dec 08, 2016 at 03:55:45PM +0000, Brian Cowan wrote:
> > Bruce, all, when I use the 4.9.0-rc8 kernel, the long lock times when contention occurs is still present. In a 5 minute run, I have 2 lock waits > 15 seconds and quite a few others over 1 sec. 
> 
> Note that all of the clients running the test need to be on that updated kernel, as does the server.
> 
> Also, all of those clients need to be mounting with NFS version at least 4.1.
> 
> If that's all done, then it'd be interesting to know how the distribution of wait times compares with the results you got in the un-updated case.  Is it about the same?  Or is it generally better, but still with some excessive waits, and still not as good as the v3 case?
> 
> And then a network trace might help debug.
> 
> --b.
> 
> > 
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Tuesday, December 6, 2016 3:48 PM
> > To: Brian Cowan <brian.cowan@hcl.com>
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: FW: File lock performance over NFSv4 degrades dramatically when lock contention is present.
> > 
> > On Tue, Dec 06, 2016 at 03:58:52PM +0000, Brian Cowan wrote:
> > > On moving an application that uses file locking from NFSv3 to NFSV4, we found that file lock/unlock times can vary wildly when lock contention is present. Our application has multiple files that have to be locked in the remote filesystem. When multiple instances (as few as 2) of the application components are running and sharing these files we are seeing lock delays in seconds as opposed to milli/microseconds. 
> > 
> > NFSv4.0 clients poll for contended locks--so after the lock's released, the server just sits there waiting for some client to retry the lock.
> > And I don't recall exactly but seconds sounds about right for those retry timeouts.
> > 
> > NFSv3 on the other hand (well, actually NLM, the sideband locking
> > protocol) has callbacks that allows the server to call back to clients waiting for contended locks.
> > 
> > NFSv4.1 adds back in those callbacks, but we only got around to implementing that recently.  If you could rerun your tests with a 4.9 or later kernel (on both client and server), it'd be interesting to see the results.
> > 
> > (There's a subtle difference between the callbacks in the v3 and v4.1 
> > cases--in the v3 case the callback itself actually granted the lock, 
> > in the v4.1 case it's just a hint to the client that this would be a 
> > good time for it to retry.  In theory 4.1 should get close to the same 
> > performance that way while avoiding some race conditions that were 
> > possible in the v3 case.)
> > 
> > --b.
> > 
> > > 
> > > We can reproduce this in multiple Linux versions (At least SuSE 11, SuSE 12, Ubuntu 14.04, Red Hat 7.x), and multiple NFS servers (Linux, Solaris, NetApp) and the issue only occurs on NFSv4 mounts. Mounting the exact same filesystem via NFSv3 eliminates the issue. We're reasonably certain that this is not a client configuration issue as additional customers are coming out of the woodwork reporting the problem. We're also reasonably certain that this is not a server issue since it's happening across multiple server platforms. 
> > > 
> > > To reproduce this outside of our application, a coworker wrote a simple lock test program (attached). When one instance of this program is run on an affected host, the lock times are < 1000us. If you then start a second instance of the application, the lock wait times have reached as long as 3 MINUTES. Unlocking doesn't take anywhere near as long, where the maximum observed unlock time being about 23 ms. 
> > > 
> > > Process we used to prove this:
> > > 1) Compiled the attached source.
> > > 2) Mounted a remote filesystem via NFSv4 (example: /mnt/nfsv4)
> > > 3) Created a temp file with 777 permissions. (/mnt/nfsv4/foo)
> > > 4) Ran one instance of the tool, redirecting the output to /tmp:
> > > ./lock1 /mnt/nfsv4/foo >> /tmp/zz1 &
> > > 5) Checked lock times after 20 seconds: 
> > > sort -rn -k3 < /tmp/zz1 | more
> > > 6) Started a second instance of the tool
> > > ./lock1 /mnt/nfsv4/foo >> /tmp/zz2 &
> > > 7) Check the lock times again, using both files:
> > > sort -rn -k3 < /tmp/zz1 | more
> > > sort -rn -k3 < /tmp/zz2 | more
> > > 
> > > What we saw was lock calls moving from the < 1000 us range to (as my coworker put it) "integral numbers of seconds." Not every lock stalls for integral numbers of seconds, but enough of them do to stall our application. Even the small percentage of > 1 second lock/unlock calls causes problems as we do a lot of file locking. 
> > > 
> > > Any/all diagnostic assistance would be greatly appreciated.
> > > 
> > > 
> > > ::DISCLAIMER::
> > > --------------------------------------------------------------------
> > > --
> > > --------------------------------------------------------------------
> > > --
> > > --------
> > > 
> > > The contents of this e-mail and any attachment(s) are confidential and intended for the named recipient(s) only.
> > > E-mail transmission is not guaranteed to be secure or error-free as 
> > > information could be intercepted, corrupted, lost, destroyed, arrive 
> > > late or incomplete, or may contain viruses in transmission. The e mail and its contents (with or without referred errors) shall therefore not attach any liability on the originator or HCL or its affiliates.
> > > Views or opinions, if any, presented in this email are solely those 
> > > of the author and may not necessarily reflect the views or opinions 
> > > of HCL or its affiliates. Any form of reproduction, dissemination, 
> > > copying, disclosure, modification, distribution and / or publication of this message without the prior written consent of authorized representative of HCL is strictly prohibited. If you have received this email in error please delete it and notify the sender immediately.
> > > Before opening any email and/or attachments, please check them for viruses and other defects.
> > > 
> > > --------------------------------------------------------------------
> > > --
> > > --------------------------------------------------------------------
> > > --
> > > --------
> > 
> > > #include <stdio.h>
> > > #include <fcntl.h>
> > > #include <unistd.h>
> > > #include <sys/types.h>
> > > #include <sys/time.h>
> > > 
> > > #define MAXBUF 4096
> > > 
> > > main(argc, argv)
> > > int argc;
> > > char *argv[];
> > > {
> > > 
> > >     int i;
> > >     int fd;
> > >     pid_t pid;
> > >     int sleep_time;
> > >     int time_taken=0;
> > >     char buffer[MAXBUF];
> > >     struct timeval t1, t2;
> > > 
> > >     setbuf(stdout, NULL);
> > >     /* Populate new block */
> > >     for(i=0; i<MAXBUF; i++)
> > >        buffer[i]='c';
> > > 
> > >     /* a single arg  - the  filename*/
> > >     if (argc != 2){
> > >        fprintf(stderr, "usage: %s <file>\n", argv[0]);
> > >        _exit(2);
> > >     }
> > > 
> > >     /* Check arg is a file can open r/w */
> > >     if ((fd=open(argv[1], O_RDWR, 0777)) <0) {
> > >        fprintf(stderr, "could not create/open %s \n", argv[1]);
> > >        _exit(1);
> > >     }
> > > 
> > > 
> > >     /* Loop forever */
> > >     while(1){
> > >            /* Reset file pointer to start of file */
> > >            if (lseek(fd, 0, SEEK_SET) < 0) {
> > >               fprintf(stderr, "could not seek to beginning of %s\n", argv[1]);
> > >               _exit(1);
> > >            }
> > > 
> > >            /* Lock entire file for exclusive access  and time how long it takes to get lock*/
> > >            gettimeofday(&t1, NULL);
> > >            if (lockf(fd, F_LOCK, 0) < 0) {
> > >               fprintf(stderr, "could not lock whole file %s\n", argv[1]);
> > >               _exit(1);
> > >            }
> > >            gettimeofday(&t2, NULL);
> > >            time_taken=(t2.tv_sec - t1.tv_sec)*1000000 + (t2.tv_usec - t1.tv_usec);
> > >               printf("lockf() took  %d us\n", time_taken);
> > > 
> > >            /* Unlock file  and time how long that takes*/
> > >            gettimeofday(&t1, NULL);
> > >            if (lockf(fd, F_ULOCK, 0) < 0) {
> > >               fprintf(stderr, "could not unlock file %s\n", argv[1]);
> > >               _exit(1);
> > >            }
> > >            gettimeofday(&t2, NULL);
> > >            time_taken=(t2.tv_sec - t1.tv_sec)*1000000 + (t2.tv_usec - t1.tv_usec);
> > >               printf("unlock() took %d us\n", time_taken);
> > > 
> > >   }
> > > _exit(0);
> > > }
