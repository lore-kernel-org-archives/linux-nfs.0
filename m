From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 2.4.19 hang (was unlink perf pb !)
Date: Tue, 13 Aug 2002 11:42:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D1E8@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17egcQ-0003Kv-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 11:42:14 -0700
To: =?iso-8859-1?Q?=27Brasseur_Val=E9ry=27?=
	 <Valery.Brasseur@atosorigin.com>
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

if your client works OK with 2.4.18 but stops with your 2.4.19+nfs
kernels, can you try hunting down exactly which kernel causes the
problem?  does 2.4.19 without any nfs patches work, for example?

> after some more investigation on my D state hang here is some 
> observations :
> 
> * I couldn't get a clear trace of state : sysrq-t was not 
> dump on a file !
> don't know why !
>   so I hand wrote extract of what I see and let ksymsoops try !
>  
>    got this : processes was in kmap or in flush_tbl !
> 
> * now after a clean boot, lauchn my prog : after a few second 
> the LA grow,
> blocked processes grow too ! (in my vmstat all the processes 
> are in block
> queue !) and only 1 waiting process !
> 
>   when in this state, I can't do  many things as all what I 
> can do seems to
> hang too !
> 
> => I was not having this probleme in 2.4.18 !
> 
> note : when this arrive I've got something like 10 to 20 Mbs 
> to nfs server.
> 
> 
> valery
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by: Dice - The leading online job board
> for high-tech professionals. Search and apply for tech jobs today!
> http://seeker.dice.com/seeker.epl?rel_code=31
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
