From: Ian Kent <raven@themaw.net>
Subject: RE: [autofs] running out of mount points
Date: Tue, 20 Jan 2004 23:11:59 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0401202258170.3291-100000@raven.themaw.net>
References: <6AB920CC10586340BE1674976E0A991D0C6C00@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: autofs mailing list <autofs@linux.kernel.org>,
     <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AixZ5-0005fF-UW
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 07:13:15 -0800
Received: from mail-04.iinet.net.au ([203.59.3.36] helo=mail.iinet.net.au)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AixZ5-0004Cg-6q
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 07:13:15 -0800
To: Greg Bradner <gregb@rhythm.com>
In-Reply-To: <6AB920CC10586340BE1674976E0A991D0C6C00@slexch2.sugarland.unocal.com>
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

On Mon, 19 Jan 2004, Ogden, Aaron A. wrote:

> 
> > -----Original Message-----
> > From: autofs-bounces@linux.kernel.org 
> > [mailto:autofs-bounces@linux.kernel.org] On Behalf Of Greg Bradner
> > Sent: Monday, January 19, 2004 9:49 AM
> > To: autofs@linux.kernel.org
> > Subject: [autofs] running out of mount points
> > 
> > 
> > I wanted to repost this plea. I am really in a bind and could use some
> 
> > help. I need to mount these users on the mail server.
> > BTW: this is with autofs 4.1.0
> > 
> 
> 
> Once you get past this hurdle you may run into another problem, you may
> find (as I did)
> that you can't actually mount 1200 filesystems... RPC will start running
> into problems
> around 800 mounts or slightly less.  I've been told that this happens
> because RPC is using
> a separate port for each NFS mount, it starts at port 800 and counts
> down to 1, so when the
> system runs out of ports it is once again unable to mount anything.
> Supposedly there is
> some work being done to rewire linux RPC so that it uses one port *per
> server* rather than
> one port per NFS mount, that change would fix the problem for any
> reasonable configuration.

I have worked on Tronds' patch for that. I posted my first attempt on 
the nfs list to see if Trond could sanity check it but he was clearly to 
busy. So I went ahead and did the best I could. This resulted in a port 
for 2.6 and 2.4 vanila kernel only. It is entirely untested and I expect 
will have problems as the depth of my understanding of the NFS subsystem 
is poor at best. I found trying to make it apply to a RedHat 2.4 kernel 
was something of a nightmare and have left it there for now.

Ian



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
