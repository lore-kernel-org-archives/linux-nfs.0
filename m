From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: Corrupt Data when using NFS on Linux -- This should be in the HOWTO
Date: Tue, 29 Oct 2002 10:07:48 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DBECE74.506@attbi.com>
References: <6440EA1A6AA1D5118C6900902745938E07D54FE2@black.eng.netapp.com> <007601c27ed6$74986240$2864a8c0@alanw> <200210291703.g9TH3FD32594@leinie.lmcg.wisc.edu> <1035912013.3dbec34dddd7e@webmail.smithconcepts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Daniel Forrest <forrest@lmcg.wisc.edu>,
	Alan Witz <awitz@magstarinc.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186aoS-0001bZ-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 10:10:00 -0800
To: "Bryan J. Smith" <b.j.smith@ieee.org>
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

Its easier with the FAQ, but the HOWTO might be the better place.
We'll take a look at it...

Tom

Bryan J. Smith wrote:

> Quoting Daniel Forrest <forrest@lmcg.wisc.edu>:
> 
>>The "guaranteed" way to create a lock file over NFS:
>>    create tempfile
>>    link tempfile lockfile (ignore return code)
>>    stat tempfile
>>If the link count is 2, then you have the lock file.  Apparently, link
>>may return success even if the link failed or return failure even if
>>the link succeeded (I don't remember which).  Doing the stat verifies
>>if you have actually created a link to the temporary file.
>>
> 
> I know the HOWTO is more for users/sysadmins, but stuff like this could really
> help in an additional "common workarounds for potential gotchas" section at the
> end of the HOWTO.
> 
> 


-- 
------------------------------------------------------------------------
Tom McNeal            trmcneal@attbi.com          (650)906-0761 (cell)
------------------------------------------------------------------------



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
