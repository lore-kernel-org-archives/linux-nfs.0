Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:36962 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760721Ab2EPXlg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 19:41:36 -0400
Subject: Re: ls stalls
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FB4397A.6060104@fhcrc.org>
Date: Wed, 16 May 2012 19:41:31 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <C7DE94F7-9A05-43C1-81EF-10136AE3394E@oracle.com>
References: <4FB43655.5040907@fhcrc.org> <4FB4397A.6060104@fhcrc.org>
To: Stuart Kendrick <skendric@fhcrc.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 16, 2012, at 7:34 PM, Stuart Kendrick wrote:

> Hi folks,
> 
> On our large memory (64GB) HPC nodes, we intermittently see what we call
> 'interactive stalls':  pauses in receiving 'ls' output.  Also, bash
> shell completion stalls, emacs stalls.  We've hacked /bin/ls to time how
> long it takes to complete and then to log diagnostic information when
> that time exceeds 3 seconds.  In some cases, the result isn't surprising
> -- a directory containing thousands or tens of thousands of files,
> hosted on slow storage, might well take seconds to display.  But most of
> the time, these stalls occur on directories containing tens or
> occasionally hundreds of files; 'ls' on such a directory normally takes
> a millisecond or less to complete.  Stalls vary in length:  most of them
> under 10s, with a significant portion under 100s, and the occasional
> stall in the 100-300s range.
> 
> I've been correlating strace output ('strace -f -tt ls {directory}')
> with packet traces.  And I see the following pattern:
> 
> (A) The stall occurs between a 'stat' on the directory and the 'open' on
> the directory ... and sometimes, though not always, between the 'open'
> and the following 'fcntl'.  Here's an example of a 10s stall:
> 
> 17:20:01.365375
> stat("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
> {st_mode=S_IFDIR|0770, st_size=327680, ...}) = 0
> 
> 17:20:11.774368
> open("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
> O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
> 
> 
> And of a ~200s stall:
> 
> 
> 10:30:01.768459
> stat("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
> {st_mode=S_IFDIR|0770, st_size=327680, ...}) = 0
> 
> 10:33:06.072659
> open("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
> O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
> 
> 10:33:28.884426 fcntl(3, F_GETFD) = 0x1 (flags FD_CLOEXEC)
> 
> 10:33:28.884600 getdents64(3, /* 683 entries */, 32768) = 32736
> 
> 
> 
> (B) On the wire, during that stall, the HPC node says nothing to the NFS
> server (sometimes literally, sometimes it is reading or writing in
> support of some other task/user, but not emitting GETATTR or READDIR or
> READDIRPLUS calls).  [No dropped frames, no TCP pathology.]
> 
> 
> (C) Network IO is noticeable:  the node is reading and/or writing,
> rapidly, with at least one of the handful of NFS servers which provide
> storage to the HPC environment.
> 
> The clients are all running OpenSuse 11.3 Teal (kernel
> 2.6.34.10-0.2-default).  The NFS servers are a mix -- Solaris 10,
> several NetApps, Windows 2008 -- backed by several different storage
> systems.
> 
> Diagrams and related information visible at
> https://vishnu.fhcrc.org/Rhino-RCA/
> 
> Insights?  Suggestions?

My starting guess is that there is some task on that client that has dirtied the pages of one of the files in the directory you are trying to list.  A GETATTR is required to flush outstanding writes to a file so the server can provide size and mtime attributes that reflect the last most recent write to that file.

Possible work-arounds: You can reduce the dirty_ratio setting on the client to force it to starting flushing outstanding writes sooner, you can change the writing applications to use synchronous writes (or flush manually), or you can alter your "ls" command so that it doesn't require a GETATTR for each file.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




