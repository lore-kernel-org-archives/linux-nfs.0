From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Wed, 04 May 2005 07:44:40 +0200
Message-ID: <42786148.1000201@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	 <17006.13241.129839.558300@cse.unsw.edu.au> <1115155275.2894.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTChN-0001fQ-31
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 22:45:29 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DTChL-0000og-Ij
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 22:45:28 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: <1115155275.2894.20.camel@localhost.localdomain>
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

> So in reference to this bug
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=150759
> it seems as if ridding the system of the journal by instead using ext2
> is fixing the problem? I can't tell if that bug has anything to do with
> providing ESTALE errors but it seems to have the same effect where you
> can't see files even though they are there. 

Yes, sounds very similar...


> 
>  Has anyone tried using the journal_data_ordered option? I am not sure
> there is a way to do that in reiser but I know it can be done with ext3.

According to the man page, "data=ordered" is the default. Have you
explicitely changed it?

I couldn't find any option to change this in reiserfs...

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
