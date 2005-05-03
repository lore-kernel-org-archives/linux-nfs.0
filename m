From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Tue, 03 May 2005 13:11:18 +0200
Message-ID: <42775C56.9000703@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	<17006.13241.129839.558300@cse.unsw.edu.au>	<1114554149.4470.5.camel@localhost.localdomain> <17006.64544.860436.620665@cse.unsw.edu.au> <4271DBB3.3090402@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Kris Vassallo <kris@linuxcertified.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSvJE-00084V-UN
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 04:11:24 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DSvJD-0004Px-CJ
	for nfs@lists.sourceforge.net; Tue, 03 May 2005 04:11:24 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <4271DBB3.3090402@bio.ifi.lmu.de>
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

> minutes. After this time, they do a "ls" and get
> 
> ls: .: Stale NFS file handle
> 
> Calling "cd .." and then "cd <former_directory>", the ls works
> again.

We just figured out that the files in the directory can be viewed when
doing "ls specific_file":

wirth [13:09] lx003umv.default 55) ls -la
ls: .: Stale NFS file handle
wirth [13:10] lx003umv.default 56) ls -la defaults.ini
-rw-------    1 tester   users          24 Apr 29 13:10 defaults.ini
wirth [13:10] lx003umv.default 57) ls -la
ls: .: Stale NFS file handle

So just "." goes stale, everything below seems to be sane. Maybe that
info is helpful...

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
