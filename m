From: Chang Li <changli_99@yahoo.com>
Subject: Re: Linux NFS client over TCP
Date: Thu, 23 Oct 2003 05:44:28 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031023124428.69700.qmail@web12004.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ACggu-0000bG-00
	for <nfs@lists.sourceforge.net>; Thu, 23 Oct 2003 07:43:56 -0700
Received: from web12004.mail.yahoo.com ([216.136.172.212])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ACeql-0000vV-1n
	for nfs@lists.sourceforge.net; Thu, 23 Oct 2003 05:45:59 -0700
To: nfs@lists.sourceforge.net
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

> --- Trond Myklebust <trond.myklebust@fys.uio.no>
> > Subject: Re: [NFS] Linux NFS client over TCP
> > 
> > >>>>> " " == Suresh Kodati <kodatisu@yahoo.com>
> > writes:
> > 
> >      > I would like to know if this is an expected
> > behavior from NFS
> >      > client side?.
> > 
> It is under Linux, yes. I probably will get round to
finishing the TCP
> active close stuff at some point, but it is not top
> of my list of
> priorities...
> 
> Cheers,
>

Trond,
I would like to know some more details.
How does nfs client know that the status has gone to
CLOSE_WAIT state?. 
NFS client does not seem to bother about the
connection status while transacting. I thought it is
rpc that takes care of reconnection.

Please let me know How we can implement this. ( I'll
give a try ).

Chang_li

__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
