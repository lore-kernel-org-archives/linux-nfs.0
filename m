From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Stale File handles keep coming back
Date: Wed, 27 Apr 2005 12:42:40 +1000
Message-ID: <17006.64544.860436.620665@cse.unsw.edu.au>
References: <1114463253.2487.73.camel@localhost.localdomain>
	<17006.13241.129839.558300@cse.unsw.edu.au>
	<1114554149.4470.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQcVe-0006yx-Su
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 19:42:42 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DQcVd-0006jI-6i
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 19:42:42 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: message from Kris Vassallo on Tuesday April 26
Sender: nfs-admin@lists.sourceforge.net
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

On Tuesday April 26, kris@linuxcertified.com wrote:
> On Tue, 2005-04-26 at 05:27, Neil Brown wrote:
> 
> > On Monday April 25, kris@linuxcertified.com wrote:
> > > I am experiencing a problem with stale file handles, and I have not been
> > > able to find an answer in the archives nor has doing anything in the
> > > readme helped. I apologize if an answer has already been posted
> > > regarding an issue such as this. After many frustrating hours of
> > > troubleshooting I am hoping for some help. The mail is long but I am
> > > hoping that it answers all the questions. 
> > 
> > Very odd...
> > 
> > The output of:
> > 
> >   echo 2048 > /proc/sys/sunrpc/rpc_debug
> >   grep . /proc/net/rpc/*/content
> >   ls -l /proc/fs/nfsd
> >   cat /proc/fs/nfs/exports
> 
> As you wished:

Thanks.  Everything looks OK.

  10.113.1.{7,8,9,13,15,16,18,20,22,23,30,31,32,35}

all seem to have authenticated OK and I suspect other clients would if
they tried.

Maybe we need to drill-down a bit more....

Once the client gets an ESTALE for a particular object, it won't try
the lookup again (because it already knows it is stale), so once the
problem is happening on the client, it might be too late to check what
is happening on the server...

Maybe if you cd up out the directory and 'ls' again from above it
might re-check with the server.

So, when it happens again, please check that the IP address of the
client really is in /proc/net/rpc/auth.unix.ip/content and then

  echo 1023 > /proc/sys/sunrpc/nfsd_debug
on the server.
Then on the client, 
  cd $HOME
  ls -l the/offending/directory

See if that works, and see what you get in the kernel logs.


NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
