Return-Path: linux-nfs-owner@vger.kernel.org
Received: from RATBERT.FHCRC.ORG ([140.107.152.19]:51860 "EHLO
	ratbert.fhcrc.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760153Ab2EPXfA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 19:35:00 -0400
Received: from ratbert.fhcrc.org (localhost.localdomain [127.0.0.1])
	by localhost (Postfix) with SMTP id ED0A868C56
	for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 16:34:59 -0700 (PDT)
Received: from dogbert.fhcrc.org (DOGBERT.FHCRC.ORG [140.107.89.15])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by ratbert.fhcrc.org (Postfix) with ESMTPS id 7412D68C47
	for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 16:34:59 -0700 (PDT)
Received: from dogbert.fhcrc.org (localhost.localdomain [127.0.0.1])
	by localhost (Postfix) with SMTP id 7A0A82580E7
	for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 16:34:19 -0700 (PDT)
Received: from zimbra-mta1.fhcrc.org (ZIMBRA-MTA1.FHCRC.ORG [140.107.89.37])
	by dogbert.fhcrc.org (Postfix) with ESMTP id 485D82580E5
	for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 16:34:19 -0700 (PDT)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra-mta1.fhcrc.org (Postfix) with ESMTP id 3EF142E0EF9
	for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 16:34:19 -0700 (PDT)
Received: from zimbra-mta1.fhcrc.org ([127.0.0.1])
	by localhost (zimbra-mta1.fhcrc.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aiAW5PX2sEDa for <linux-nfs@vger.kernel.org>;
	Wed, 16 May 2012 16:34:19 -0700 (PDT)
Received: from [140.107.9.116] (SHAKTI.FHCRC.ORG [140.107.9.116])
	by zimbra-mta1.fhcrc.org (Postfix) with ESMTPSA id 1162E2E0ED1
	for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 16:34:19 -0700 (PDT)
Message-ID: <4FB4397A.6060104@fhcrc.org>
Date: Wed, 16 May 2012 16:34:18 -0700
From: Stuart Kendrick <skendric@fhcrc.org>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: ls stalls
References: <4FB43655.5040907@fhcrc.org>
In-Reply-To: <4FB43655.5040907@fhcrc.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

On our large memory (64GB) HPC nodes, we intermittently see what we call
'interactive stalls':  pauses in receiving 'ls' output.  Also, bash
shell completion stalls, emacs stalls.  We've hacked /bin/ls to time how
long it takes to complete and then to log diagnostic information when
that time exceeds 3 seconds.  In some cases, the result isn't surprising
-- a directory containing thousands or tens of thousands of files,
hosted on slow storage, might well take seconds to display.  But most of
the time, these stalls occur on directories containing tens or
occasionally hundreds of files; 'ls' on such a directory normally takes
a millisecond or less to complete.  Stalls vary in length:  most of them
under 10s, with a significant portion under 100s, and the occasional
stall in the 100-300s range.

I've been correlating strace output ('strace -f -tt ls {directory}')
with packet traces.  And I see the following pattern:

(A) The stall occurs between a 'stat' on the directory and the 'open' on
the directory ... and sometimes, though not always, between the 'open'
and the following 'fcntl'.  Here's an example of a 10s stall:

17:20:01.365375
stat("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
{st_mode=S_IFDIR|0770, st_size=327680, ...}) = 0

17:20:11.774368
open("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3


And of a ~200s stall:


10:30:01.768459
stat("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
{st_mode=S_IFDIR|0770, st_size=327680, ...}) = 0

10:33:06.072659
open("/shared/silo_r/xxx/colongwas_archive/plco-sshfs/pancreatic-panscan-dbgap/panscan-work/610-gtc",
O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3

10:33:28.884426 fcntl(3, F_GETFD) = 0x1 (flags FD_CLOEXEC)

10:33:28.884600 getdents64(3, /* 683 entries */, 32768) = 32736



(B) On the wire, during that stall, the HPC node says nothing to the NFS
server (sometimes literally, sometimes it is reading or writing in
support of some other task/user, but not emitting GETATTR or READDIR or
READDIRPLUS calls).  [No dropped frames, no TCP pathology.]


(C) Network IO is noticeable:  the node is reading and/or writing,
rapidly, with at least one of the handful of NFS servers which provide
storage to the HPC environment.

The clients are all running OpenSuse 11.3 Teal (kernel
2.6.34.10-0.2-default).  The NFS servers are a mix -- Solaris 10,
several NetApps, Windows 2008 -- backed by several different storage
systems.

Diagrams and related information visible at
https://vishnu.fhcrc.org/Rhino-RCA/

Insights?  Suggestions?

--sk

Stuart Kendrick
Fred Hutchinson Cancer Research Center
Seattle, WA USA


