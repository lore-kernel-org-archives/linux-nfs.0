From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rpc.mountd + rpc.nfsd
Date: Tue, 3 Sep 2002 20:18:01 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15732.35929.482032.954554@notabene.cse.unsw.edu.au>
References: <3D7363A7.8090906@linkvest.com>
	<15732.7907.19389.156631@notabene.cse.unsw.edu.au>
	<3D745D10.4040409@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <Jean-Eric.Cuendet@linkvest.com>
In-Reply-To: message from Jean-Eric Cuendet on Tuesday September 3
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tuesday September 3, Jean-Eric.Cuendet@linkvest.com wrote:
> 
> In fact, I thought of a completely userspace daemon. I took 
> nfs-server-userspace-2.2b47 from the net and wondered why there was 2 
> daemons while one is IMHO enough.
> So, separating things between things that relates is sometimes good, but 
> sometimes, it add complexity.
> Any comment? Why 2 daemons in userspace. And the 2 run as root (I think...)

Probably conceptually simpler.... but you are getting into ancient
history here.  The user-space NFS server has it's origins well over a
decade ago (about 15 years I think) and has passed through many hands
on the way.  Finding a definitive answer would be hard.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
