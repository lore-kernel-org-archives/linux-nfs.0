From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS causing kernel panics
Date: Fri, 30 Apr 2004 15:59:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083355182.13656.15.camel@lade.trondhjem.org>
References: <E1BJca7-0004Xp-Jp@sc8-sf-mx1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJeAm-0000Zk-SG
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 12:59:48 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BJeAl-0001ZY-Ei
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 12:59:47 -0700
To: Randy Paries <paries@knology.net>
In-Reply-To: <E1BJca7-0004Xp-Jp@sc8-sf-mx1.sourceforge.net>
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

On Fri, 2004-04-30 at 14:17, Randy Paries wrote:
> Hello,
>  
> I have a machine that is a nfs client. It keeps having kernel panics
>  
> i have included some from the log file
>  

That Oops trace looks like it has nothing to do with NFS: it is rather
something in the socket "poll()" support that is messing up.

I suggest you report it to RedHat's Bugzilla... (bugzilla.redhat.com
IIRC).

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
