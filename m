From: "Pedro M. Rodrigues" <pmanuel@myrealbox.com>
Subject: Re: Solaris 8 Server / RedHat 7.2 Clients
Date: Sat, 20 Jul 2002 15:02:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D397B7B.3064.98C41C@localhost>
References: <200207200214.g6K2EkI32355@dymwsm10.mailwatch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp-send.myrealbox.com ([192.108.102.143])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Vtu3-0003xa-00
	for <nfs@lists.sourceforge.net>; Sat, 20 Jul 2002 06:04:07 -0700
To: nfs@lists.sourceforge.net,
              Christopher Penney <cpenney@ford.com>
In-Reply-To: <200207200214.g6K2EkI32355@dymwsm10.mailwatch.com>
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

   Using tcp instead of udp would fit better in your environment, 
because of your router in between. And the fact that you are mixing 
gigabit server and 100mb clients doesn't help. If it works ok good, 
but under load you may see packet loss and consequent resending. 
Translation: bad performance. But you would need to patch those RH 
7.2 clients to get acceptable nfs over tcp. 


/Pedro

On 19 Jul 2002 at 22:14, Christopher Penney wrote:

> 
> Is there a preferred setup when using a Solaris 8 NFS server with only
> RedHAt 7.2 clients?  The server is exporting a 1TB file system to
> several Compaq Alpha's running RedHat 7.2 (2.4.9-32smp) that are
> sitting behind a NAT router.
> 
> Right now, I'm automounting the file system's user dirs with the
> following options:
> 
>    rw,intr,hard,bg,wsize=8192,rsize=8192,nfsvers=3,udp
> 
> Should I be using a 32k w/rzise with a Solaris 8 server?  Anything
> else I'm missing?  Anything I shoudl take into consideration with a
> NAT router in between?  Everything seems to be working well, but I'm
> looking for any improvements I can make.
> 
> Oh, it's all gigabit ethernet except for each clients connection to
> the switch, which is 100mbit.
> 
>    Chris
> 
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
