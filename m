From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Mon, 09 May 2005 08:04:01 +0200
Message-ID: <427EFD51.5090800@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	 <17006.13241.129839.558300@cse.unsw.edu.au>	 <1114554149.4470.5.camel@localhost.localdomain>	 <17006.64544.860436.620665@cse.unsw.edu.au>	 <4271DBB3.3090402@bio.ifi.lmu.de>  <42775C56.9000703@bio.ifi.lmu.de> <1115252134.2523.87.camel@localhost.localdomain> <427B10F7.3090600@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Kris Vassallo <kris@linuxcertified.com>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DV1NM-0007tT-37
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 23:04:20 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DV1NK-0005SU-8F
	for nfs@lists.sourceforge.net; Sun, 08 May 2005 23:04:19 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <427B10F7.3090600@bio.ifi.lmu.de>
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

Frank Steiner wrote

>  > That client-side patch can do nothing to prevent errors from being
>  > returned if a server is erroneously generating ESTALE.
>  >
>  > It will just make it unnecessary to do the equivalent of "cd
>  > `pwd`" (i.e. rewalk the path) on the client once the server manages to
>  > sort itself out.
> 
> I'm a bit confused if this patch would help or not. I will test it.

Applying that patch to the SuSE kernel 2.6.8-24.14 seems to solve the
stale problem for me. Well, reading Tronds explanation, I guess it
does not really "solve" but maybe just hide the bug... If the client
does an equivlate of "cd `pwd`", then it will just recover from the
stale handle without the user recognizing it at all.

Anyway, with the normal SuSE 2.6.8-24.14 I get a stale "." whenever
I start firefox on the client and chdir to the firefox profile
directory. After 30 minutes the shell reliably has a stale directory.

With the patch applied and the client running the patched kernel,
(the server doesn't need to) there is no stale in this situation
after more than one day and that's all I need to make my users happy.

People in our department running server and client with 2.6.11 report
they still have massive problems with stale NFS handles, so it looks
like this patch just helped for a certain problem in 2.6.8...

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
