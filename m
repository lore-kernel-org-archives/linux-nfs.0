From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: Must statd be running before nfs client makes mounts?
Date: Mon, 16 Sep 2002 07:12:59 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020916071259.B1149@lucon.org>
References: <20020915225226.GI11002@perlsupport.com> <15749.5917.443602.600792@notabene.cse.unsw.edu.au> <20020915164956.A21841@lucon.org> <15749.7947.298657.940521@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qwcd-0008JZ-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Sep 2002 07:13:07 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15749.7947.298657.940521@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Mon, Sep 16, 2002 at 10:00:11AM +1000
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

On Mon, Sep 16, 2002 at 10:00:11AM +1000, Neil Brown wrote:
> On Sunday September 15, hjl@lucon.org wrote:
> > On Mon, Sep 16, 2002 at 09:26:21AM +1000, Neil Brown wrote:
> > > 
> > >   (start devices, raid, etc)
> > >  1/ mount local filesystems
> > >   (start network, bind, portmap)
> > 
> > I am thinking to write a kernel patch to set nlm_udpport and
> > nlm_tcpport. The current scheme works only with module and /proc
> > won't work with module. I'd like to be able to set ports used by
> > lockd according to /etc/services. In my case, I have
> > 
> > nlockmgr        3003/tcp
> > nlockmgr        3003/udp
> > 
> > But I have to hard code them in my kernel.
> 
> You shouldn't need to hard code them,  kernel parameters:
>    lockd.udpport=3003 lockd.tcpport=3003
> should work fine (unless that is what you mean by hardcoding)

It is still hardcoding since can't change it at runtime.

> 
> However I don't see a problem with doing this via a sysctl, quite
> possibly a sysctl under /proc/sys/sunrpc/  (as it is an RPC service).
> 

Does it work with sunrpc as module?


H.J.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
