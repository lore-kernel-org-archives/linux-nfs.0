From: "Bryan J. Smith" <b.j.smith@ieee.org>
Subject: Re: Corrupt Data when using NFS on Linux -- This should be in the HOWTO
Date: Tue, 29 Oct 2002 13:23:43 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035915823.3dbed22fa9dc0@webmail.smithconcepts.com>
References: <6440EA1A6AA1D5118C6900902745938E07D54FE2@black.eng.netapp.com> <007601c27ed6$74986240$2864a8c0@alanw> <200210291703.g9TH3FD32594@leinie.lmcg.wisc.edu> <1035912013.3dbec34dddd7e@webmail.smithconcepts.com> <3DBECE74.506@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Bryan J. Smith" <b.j.smith@ieee.org>,
  Daniel Forrest <forrest@lmcg.wisc.edu>, Alan Witz <awitz@magstarinc.com>,
  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from knight.01.dios.net ([65.222.230.112] helo=taz2.fiberhosting.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186b1q-0008RM-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 10:23:50 -0800
To: Tom McNeal <trmcneal@attbi.com>
In-Reply-To: <3DBECE74.506@attbi.com>
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


Quoting Tom McNeal <trmcneal@attbi.com>:
> Its easier with the FAQ, but the HOWTO might be the better place.
> We'll take a look at it...

Maybe just a "Top 10 Differences Between NFS And Local"

- Mounts in exported filesystems are not automatically exported
- Locking issues and accomodation in scripts/programs
- Etc...

I think it would go a long way to helping many.

-- 
Bryan J. Smith, E.I.            Contact Info:  http://thebs.org
A+/i-Net+/Linux+/Network+/Server+ CCNA CIWA CNA SCSA/SCWSE/SCNA
---------------------------------------------------------------
           limit      guilt   =     { psychopath,
         remorse->0                    innocent }



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
