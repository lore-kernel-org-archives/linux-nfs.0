From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: Lock recovery doesn't work in debian statd/lockd ordering
Date: Fri, 13 Sep 2002 09:37:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020913093720.A32168@lucon.org>
References: <15743.63908.531152.357021@notabene.cse.unsw.edu.au> <wv1y7z6en4.fsf@freeze.oslo.dnmi.no> <15744.7383.324897.912595@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Phillips <a.phillips@met.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ptRi-0005nL-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Sep 2002 09:37:30 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15744.7383.324897.912595@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Thu, Sep 12, 2002 at 02:49:27PM +1000
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Sep 12, 2002 at 02:49:27PM +1000, Neil Brown wrote:
> On  September 12, a.phillips@met.no wrote:
> > >>>>> "Neil" == Neil Brown <neilb@cse.unsw.edu.au> writes:
> > 
> >     Neil>  I just noticed that lock recovery doesn't work with a
> >     Neil> Debian NFS server.  i.e.  server shuts down, restarts, and
> >     Neil> the client *Doesn't* reclaim the locks.
> > 
> > Um, which version ? On my woody box lockd is started in nfs-common
> > after statd still though :-
> 
> /sbin/rpc.lockd is an aberation that only applies to a small range of
> kernels, about 2.2.14 to 2.2.17 I think.
> 

Just for the record, I have a need to run the nlockmgr service at a
fixed port.  I have

nlockmgr        3003/tcp
nlockmgr        3003/udp

in my /etc/services. But I have to hard code it in my kernel. No, I
don't use kernel modules.  It will be nice to for rpc.lockd to passes
the port number to kernel. It doesn't have to start lockd.


H.J.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
