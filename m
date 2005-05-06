From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Fri, 06 May 2005 08:38:47 +0200
Message-ID: <427B10F7.3090600@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	 <17006.13241.129839.558300@cse.unsw.edu.au>	 <1114554149.4470.5.camel@localhost.localdomain>	 <17006.64544.860436.620665@cse.unsw.edu.au>	 <4271DBB3.3090402@bio.ifi.lmu.de>  <42775C56.9000703@bio.ifi.lmu.de> <1115252134.2523.87.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTwUU-0005pd-4T
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 23:39:14 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DTwUR-0002RQ-JZ
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 23:39:14 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: <1115252134.2523.87.camel@localhost.localdomain>
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

Kris Vassallo wrote

> Ok a question for you. Let me explain what I am noticing: As soon as a
> client gets the stale file error, I go to the actual NFS server, and do
> a ls in the directory in question. Then without doing anything else, the
> client does another ls and then the contents can be seen. I don't know
> exactly what an ls does that would make the clients suddenly work again.
> 
> Are you able to do something similar?

No. The client still gets the stale handle. However, it works again
if I do  "cd `pwd`" on the client. So, reading Tronds comment

 > That client-side patch can do nothing to prevent errors from being
 > returned if a server is erroneously generating ESTALE.
 >
 > It will just make it unnecessary to do the equivalent of "cd
 > `pwd`" (i.e. rewalk the path) on the client once the server manages to
 > sort itself out.

I'm a bit confused if this patch would help or not. I will test it.



This might be interesting for Olaf: The problem does not exist in the
kotd sles9-i386/SLES9_SP2_BRANCH/

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
