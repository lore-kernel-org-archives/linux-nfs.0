From: Brian Tinsley <btlists@emageon.com>
Subject: Re: nfs failover
Date: Sat, 10 Jan 2004 22:55:37 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1073796936.2771.18.camel@dragonball>
References: <20040111030238.18638.qmail@web12607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=-u0IsBsyoNz+VGkOHp2lU"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AfXde-0003QD-Ke
	for nfs@lists.sourceforge.net; Sat, 10 Jan 2004 20:55:50 -0800
Received: from [63.162.183.61] (helo=emgexg01.emgdom001.emageon.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AfXde-0006dr-At
	for nfs@lists.sourceforge.net; Sat, 10 Jan 2004 20:55:50 -0800
To: Eric Ford <oscar_install@yahoo.com>
In-Reply-To: <20040111030238.18638.qmail@web12607.mail.yahoo.com>
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


--=-u0IsBsyoNz+VGkOHp2lU
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

There are some specific events that must occur in order to make NFS
server failover happen. You should search the mailing list archives for
the linux-ha software (a.k.a., heartbeat) for further details. NFS
server failover has been detailed there quite extensively over the past
couple of years. And if you do not use linux-ha for clustering
(especially in the context you describe here), I suggest you give it a
try.


On Sat, 2004-01-10 at 21:02, Eric Ford wrote:

> Hello, everybody
>  
> I installed nfs on my cluster system, two head nodes(one is primary
> and another is backup) with two clients. They use NFS to store and
> transfer data between server and clients. But whenever failover
> happens, the client can't connect to backup server although 
> backup server has the same IP and hostname and same configuration at
> that time.
>  
> "NFS server is not responding, still trying" 
>  
> I use this command: #service nfs restart    on backup server, it is
> not useful.
>  
> What should I do on backup server so that client can get connection
> with it? By the way I use Pfilter (iptables) on both servers.
> 
> Thank you
> 
> Eric
> 
> 
> ______________________________________________________________________
> Do you Yahoo!?
> Yahoo! Hotjobs: Enter the "Signing Bonus" Sweepstakes

--=-u0IsBsyoNz+VGkOHp2lU
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.0.8">
</HEAD>
<BODY>
There are some specific events that must occur in order to make NFS server failover happen. You should search the mailing list archives for the linux-ha software (a.k.a., heartbeat) for further details. NFS server failover has been detailed there quite extensively over the past couple of years. And if you do not use linux-ha for clustering (especially in the context you describe here), I suggest you give it a try.<BR>
<BR>
<BR>
On Sat, 2004-01-10 at 21:02, Eric Ford wrote:
<BLOCKQUOTE TYPE=CITE>
    <FONT COLOR="#737373"><I>Hello, everybody<BR>
    &nbsp;<BR>
    I installed nfs on my cluster system, two head nodes(one is primary and another is backup) with two clients. They use NFS to store and transfer data between server and clients. But whenever failover happens, the client can't connect to backup server although <BR>
    backup server&nbsp;has the same IP and hostname and same configuration at that time.<BR>
    &nbsp;<BR>
    &quot;NFS server is not responding, still trying&quot;&nbsp;<BR>
    &nbsp;<BR>
    I use this command: #service nfs restart&nbsp;&nbsp;&nbsp; on backup server, it is not useful.<BR>
    &nbsp;<BR>
    What should I do on backup server so that client can get connection with it? By the way I use Pfilter (iptables) on both servers.<BR>
    <BR>
    Thank you<BR>
    <BR>
    Eric<BR>
    <BR>
    
<HR SIZE="1">
Do you Yahoo!?<BR>
    Yahoo! Hotjobs: </FONT><A HREF="http://pa.yahoo.com/*http://us.rd.yahoo.com/hotjobs/mail_footer_email/evt=21482/*http://hotjobs.sweepstakes.yahoo.com/signingbonus"><U>Enter the &quot;Signing Bonus&quot; Sweepstakes</U></I></A>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-u0IsBsyoNz+VGkOHp2lU--



-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
