From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Stale File handles keep coming back
Date: Fri, 29 Apr 2005 16:03:23 +0200
Message-ID: <42723EAB.3070103@bio.ifi.lmu.de>
References: <1114463253.2487.73.camel@localhost.localdomain>	<17006.13241.129839.558300@cse.unsw.edu.au>	<1114554149.4470.5.camel@localhost.localdomain> <17006.64544.860436.620665@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Kris Vassallo <kris@linuxcertified.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DRW7M-0003WE-DC
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 07:05:20 -0700
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DRW7K-0001mT-TV
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 07:05:20 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17006.64544.860436.620665@cse.unsw.edu.au>
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

One more info:

It seems that we can easily reproduce the problem when
a) an application does some work in a directory and
b) a shell is running in the same directory and left unused for some
    time (about 45 minutes seem to be enough).

Then the shell encounters the "stale NFS handle" when it tries to do
sth again.

Scenarios are e.g. an emacs running and writing a .tex file every
few minutes, and a shell is used to call "latex ...". 40 minutes of
editing with emacs without using the shell result in a stale NFS
handle when calling latex in the shell after that time.

Or running a firefox and having the shell chdir to
~/.mozilla/firefox/<the defaults user profile directory>
I guess firefox is writing the cache or sth. else. Again, the shell
will stale when left untouched for about 40 minutes.

Maybe this can help to reproduce the bug.

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
