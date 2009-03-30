From: Giulio Troccoli <Giulio.Troccoli-xnMMdYoS6WpEKMMhf/gKZA@public.gmane.org>
Subject: Re: [NFS] Compileing nfs-utils 1.1.5 on RHEL4 fails in tcpwrapper.c
Date: Mon, 30 Mar 2009 10:06:34 +0100
Message-ID: <6680A70380E6BA44A2D94ED7085718EE066A0807B0@ln1exc03>
References: <6680A70380E6BA44A2D94ED7085718EE066A08079D@ln1exc03>
	<49CCDBD2.2000709@RedHat.com>
	<6680A70380E6BA44A2D94ED7085718EE066A0807AB@ln1exc03>
	<49CD07F5.1070005@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: 'Steve Dickson' <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:41702 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758266AbZC3JHl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2009 05:07:41 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LoDSy-0001td-9r
	for linux-nfs@vger.kernel.org; Mon, 30 Mar 2009 20:07:36 +1100
In-Reply-To: <49CD07F5.1070005-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> > From time to time the build failes becuase some files are not
> > available when they are compiled. This is not strictly
> true, the file
> > is available but the building machine is told it's not.
> Make sure the time on all the machines are synced with
> something like ntpd.

Could you explain to me why the time is important? It might sound as a silly question, but as I see it it's just one portion of a file system in the remote machine mounted on the file system on the building machine.

> > I don't know much about NFS and the option I chose for the
> configure
> > script are just becuase otherwise it didn't compile. So, do
> you guys
> > think that even without nfsv4, gss and tcp-wrapper I would
> achive what I need?
> Not clear... There is a very good change running such a new
> nfs-utils on an legacy release might cause more problem...

Sorry, now that I read it again I see it's not very clear.

The files on the remote machine are only read by the building machine. Nothing is written on the NFS mounted file system by the building machine. NFS is used so that we can share source code among differente building machines. To achive this, do I need nfsv4, gss and tcp-wrapper? In other words, what are nfsv4, gss and tcp-wrapper?

Thanks for your help, it's very much appreciated.

Giulio


Linedata Services (UK) Ltd
Registered Office: Bishopsgate Court, 4-12 Norton Folgate, London, E1 6DB
Registered in England and Wales No 3027851    VAT Reg No 778499447





------------------------------------------------------------------------------
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

