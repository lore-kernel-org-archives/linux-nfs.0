From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 10:56:45 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E53C55D.1FCF2982@amis.com>
References: <Pine.GSO.4.40.0302191211380.29315-100000@bodoni>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lYSd-0005Mu-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 09:56:47 -0800
To: Fabrizio Nesti <nesti@medialab.sissa.it>
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

Fabrizio,

2.4.20 NFS server testing -- I had been using bonnie numbers to judge
performance. Users and applications had not reported problems. I had not tried
your tar -xf cvs.tar test.

I just tried your tar -xf cvs-1.11.5.tar test and I see numbers like yours
(except I don't see super fast solaris NFS numbers)

Client		Server		Time
-------------------------------------
solaris7	2.4.20		27.3
solaris7	solaris9	26.9
solaris9	solaris7	25.3
2.4.18		2.4.20		 7.0 (defaults to async mounts right?)
2.4.20		2.4.18		15.1
linux local (no NFS)		 1.2 (including sync) 

I think what we are seeing is partially the overhead in the creation of 500+
small files...

I'm not sure there is a major NFS UDP/TCP problem here -- but the differences
between your sun server and your linux server are interesting. Perhaps there is
a sync option that is making those numbers look different?

My solaris boxes are UFS. (are you runing veritas?)
My linux boxes are reiserfs.
The above numbers are on 100M network. 

Please try bonnie tests for additional insights. Different tests show different
bottlenecks and advantages. Bonnie testing usually shows other areas where linux
NFS can do better than solaris NFS. 

eric



Fabrizio Nesti wrote:
> So, if it is not UDP/TCP or r/wsize the cause, what can it be?
> Even more, after the email from
> 
> > Eric Whiting <ewhiting@amis.com>
> > ...
> > We are getting good NFS numbers with 2.4.20 UDP NFS servers against solaris
> > [89] clients.
> 
> So Eric, can you please show your configuration?
> 
> Also it is strange that a standard out-of-the-box RH8.0 on that big server
> does perform so bad. Knowing this in advance, we wouldn't have chosen
> linux for serving... :(
> 
> Ok,
> thanks and ciao,
> Fabrizio


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
