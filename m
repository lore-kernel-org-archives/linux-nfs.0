From: dwight@supercomputer.org
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Mon, 05 Jan 2004 09:31:36 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401051731.i05HVaa15457@supercomputer.org>
References: <raven@themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AdYZb-0004Qp-NA
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 09:31:27 -0800
Received: from supercomputer.org ([69.17.34.169] helo=mail.supercomputer.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AdYZb-0006Xm-Cp
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 09:31:27 -0800
To: Ian Kent <raven@themaw.net>
In-Reply-To: Message from Ian Kent <raven@themaw.net>
   of "Wed, 31 Dec 2003 09:55:11 +0800." <Pine.LNX.4.33.0312310858190.5698-100000@wombat.indigo.net.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Ian Kent wrote:
> Currently I'm running the RedHat 2.4.20-20.7 kernel.
> 
> I used UDP transport for a long time but have recently changed to TCP for
> nearly all my clients.
> ...
> 
> My usage is largely read.
> 
> Performance has improved quite a bit as the kernel version has increased.
> I can get around 80% (ie. 80% wire speed) the throughput of a 'similar'
> Sun. Problem is that most of the Sparc clients can saturate 100Mb (onto a
> gigabit backbone) so I don't really know what the difference is.
> 
> Ian

Thanks for the information, Ian.

So if I understand you correctly, you are saying that your performance for Linux clients and Solaris clients with a Solaris server is the same? Or that any
difference is not notiable?

Would you happen to know what throughput you are seeing with the Linux 
client? My own, as reported by Ethereal, is about 11 Mbs in this case.

My transactions are a combination of read and write (mimicking the common
behavior that we use in a production environment). I appreciate the information;
I'll try a test of pure reads.

And yes, I too have saturated a 100-Mb switch before, though not with NFS.
The statistics on the switch in the production environment show that we're
nowhere near saturating the switch. For my test environment, there's almost
nothing else going on at the time (I.e. one client, one server). While I could
just use a cross-over cable and eliminate the switch, I don't see any information
indicating that this would improve things at this time.

Best Regards,

	-dwight-



-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
