From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] Compileing nfs-utils 1.1.5 on RHEL4 fails in tcpwrapper.c
Date: Tue, 31 Mar 2009 15:50:23 -0400
Message-ID: <49D273FF.8060701@RedHat.com>
References: <6680A70380E6BA44A2D94ED7085718EE066A08079D@ln1exc03>
	<49CCDBD2.2000709@RedHat.com>
	<6680A70380E6BA44A2D94ED7085718EE066A0807AB@ln1exc03>
	<49CD07F5.1070005@RedHat.com>
	<6680A70380E6BA44A2D94ED7085718EE066A0807B0@ln1exc03>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Giulio Troccoli <Giulio.Troccoli-xnMMdYoS6WpEKMMhf/gKZA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34839 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663AbZCaT4F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 15:56:05 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Lok3z-0004ym-3V
	for linux-nfs@vger.kernel.org; Wed, 01 Apr 2009 06:55:59 +1100
In-Reply-To: <6680A70380E6BA44A2D94ED7085718EE066A0807B0@ln1exc03>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Giulio Troccoli wrote:
>>> From time to time the build failes becuase some files are not
>>> available when they are compiled. This is not strictly
>> true, the file
>>> is available but the building machine is told it's not.
>> Make sure the time on all the machines are synced with
>> something like ntpd.
> 
> Could you explain to me why the time is important? It might sound as a silly question, but as I see it it's just one portion of a file system in the remote machine mounted on the file system on the building machine.
> 
>>> I don't know much about NFS and the option I chose for the
>> configure
>>> script are just becuase otherwise it didn't compile. So, do
>> you guys
>>> think that even without nfsv4, gss and tcp-wrapper I would
>> achive what I need?
>> Not clear... There is a very good change running such a new
>> nfs-utils on an legacy release might cause more problem...
> 
> Sorry, now that I read it again I see it's not very clear.
> 
> The files on the remote machine are only read by the building machine.
> Nothing is written on the NFS mounted file system by the building 
> machine. NFS is used so that we can share source code among 
> differente building machines. To achive this, do I need nfsv4, gss 
> and tcp-wrapper? 
No. You do not need those to achive what your are looking for.

> In other words, what are nfsv4, gss and tcp-wrapper?
nfsv4 - is the latest NFS protocol version
gss - used to secure NFS mounts
tcp-wrapper - is a mechanism to allow or deny hosts access to
              your NFS server.

> 
> Thanks for your help, it's very much appreciated.
np..

steved.

------------------------------------------------------------------------------
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

