From: Maurice Volaski <mvolaski@aecom.yu.edu>
Subject: Re: [Q] Why is my NFSv4 client trying to contact the
 portmapper?
Date: Thu, 14 Sep 2006 16:41:22 -0400
Message-ID: <a0624041ac12f6bddf467@[129.98.90.227]>
References: <mailman.63002.1155542509.19399.nfs@lists.sourceforge.net>	
	<a06240411c12deeab9cb6@[129.98.90.227]>	
	<1158241846.5308.18.camel@lade.trondhjem.org>	
	<a06240417c12f34ab04be@[129.98.90.227]>
	<1158256014.5879.18.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNy38-0008NM-Rw
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 13:43:06 -0700
Received: from mailgw.aecom.yu.edu ([129.98.1.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GNy35-0001Xs-9C
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 13:43:04 -0700
In-Reply-To: <1158256014.5879.18.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

>On Thu, 2006-09-14 at 13:07 -0400, Maurice Volaski wrote:
>>  >  > So it appears the portmapper and TCP 111 is required after all.
>>  >>  What's going on?
>>  >
>>  >Are you using rpcsec_gss? The rpc.gssd daemon appears to never set the
>>
>>  No, neither computer even has the rpcsec_gss stuff installed.
>
>All I can say, then, is that this works for me.

Well, the only reason it does not work for me is simply because I 
have 111 blocked on the server. If I allow it through, nfs does 
indeed work. But the documentation appears to be claiming that ALL 
client-server communication takes place over 2049. Is it just a 
documentation bug?

Here the mount command on the client attempts to access the 
portmapper of the server on port 111:

Sep 14 12:23:34 matrix [17193703.828000] nfs outputIN= OUT=eth0 
SRC=129.98.90.163 DST=129.98.90.11 LEN=60 TOS=0x00 PREC=0x00 TTL=64 
ID=33189 DF PROTO=TCP SPT=60446 DPT=111 WINDOW=5840 RES=0x00 SYN 
URGP=0
-- 

Maurice Volaski, mvolaski@aecom.yu.edu
Computing Support, Rose F. Kennedy Center
Albert Einstein College of Medicine of Yeshiva University

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
