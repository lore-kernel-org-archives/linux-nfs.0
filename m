From: Eric Ford <oscar_install@yahoo.com>
Subject: nfs failover
Date: Sat, 10 Jan 2004 19:02:38 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040111030238.18638.qmail@web12607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-191229932-1073790158=:18407"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AfVs6-0007Zn-TQ
	for nfs@lists.sourceforge.net; Sat, 10 Jan 2004 19:02:38 -0800
Received: from web12607.mail.yahoo.com ([216.136.173.230])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AfVs6-0006nJ-Ly
	for nfs@lists.sourceforge.net; Sat, 10 Jan 2004 19:02:38 -0800
To: nfs@lists.sourceforge.net
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

--0-191229932-1073790158=:18407
Content-Type: text/plain; charset=us-ascii

Hello, everybody
 
I installed nfs on my cluster system, two head nodes(one is primary and another is backup) with two clients. They use NFS to store and transfer data between server and clients. But whenever failover happens, the client can't connect to backup server although 
backup server has the same IP and hostname and same configuration at that time.
 
"NFS server is not responding, still trying" 
 
I use this command: #service nfs restart    on backup server, it is not useful.
 
What should I do on backup server so that client can get connection with it? By the way I use Pfilter (iptables) on both servers.

Thank you

Eric


---------------------------------
Do you Yahoo!?
Yahoo! Hotjobs: Enter the "Signing Bonus" Sweepstakes
--0-191229932-1073790158=:18407
Content-Type: text/html; charset=us-ascii

<DIV>Hello, everybody</DIV>
<DIV>&nbsp;</DIV>
<DIV>I installed nfs on my cluster system, two head nodes(one is primary and another is backup) with two clients. They use NFS to store and transfer data between server and clients. But whenever failover happens, the client can't connect to backup server although </DIV>
<DIV>backup server&nbsp;has the same IP and hostname and same configuration at that time.</DIV>
<DIV>&nbsp;</DIV>
<DIV>"NFS server is not responding, still trying"&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>I use this command: #service nfs restart&nbsp;&nbsp;&nbsp; on backup server, it is not useful.</DIV>
<DIV>&nbsp;</DIV>
<DIV>What should I do on backup server so that client can get connection with it? By the way I use Pfilter (iptables) on both servers.</DIV>
<P>Thank you</P>
<P>Eric</P><p><hr SIZE=1>
Do you Yahoo!?<br>
Yahoo! Hotjobs: <a href="http://pa.yahoo.com/*http://us.rd.yahoo.com/hotjobs/mail_footer_email/evt=21482/*http://hotjobs.sweepstakes.yahoo.com/signingbonus">Enter the "Signing Bonus" Sweepstakes</a>
--0-191229932-1073790158=:18407--


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
