From: Steve Dickson <SteveD@redhat.com>
Subject: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Fri, 16 Jan 2009 11:22:41 -0500
Message-ID: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48429 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757976AbZAPQZ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 11:25:26 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Very recently patches were added to the mainline kernel that
enabled the use of trace points. This patch series takes
advantage of those patch by introducing trace points 
to the mounting path of NFS mounts. Its hoped these
trace points can be used by system administrators to
identify why NFS mounts are failing or hang in 
production kernels.

IMHO, one general problem with today's "canned" NFS debugging today is it 
becomes very verbose very quickly.... "I get here" and "I get there" type of 
debugging statements. Although they help trace the code but very rarely 
shows/defines what the actual problem was. So what I've try to do is 
"define the error paths" by putting a trace point at every error exit 
in hopes to define where and why things broke. 

So the ultimate goal would be to replace all the dprintks with trace points
but still be able to enable them through the rpcdebug command (although we
might want to think about splitting the command out into three different 
commands nfsdebug, nfsddebug, rpcdebug). Since trace points have very little
overhead, a set of trace points could be enable in production with have
little or no effect on functionality or performance.

Another advantage with trace points is the type and amount of
information that can be retrieved. With these trace points, I'm
passing in the error code as well as the data structure[s] associated
with that error. This allows the "canned" information that IT people
would used (via the rpcdebug command which would turn on a group of
trace points) as well as more detailed information that kernel developers 
can used (via systemtap scripts which would turn on individual trace
points).

Patch summary:
    * fs/nfs/client.c

    * fs/nfs/getroot.c

    * fs/nfs/super.c

      The based files where traces where added.

    * include/trace/nfs.h

    * kernel/trace/Makefile

    * kernel/trace/nfs-trace.c

      The overhead of added the trace points and then converting them
      into trace marks			.

    * samples/nfs/nfs_mount.stp

      The systemtap script used to access the trace marks. I probably
      should have documented the file better, but the first three
      functions in the file are how structures are pulled from the
      kernel. The rest are probes used to active the trace markers.


Comments... Acceptance?? 

steved.


