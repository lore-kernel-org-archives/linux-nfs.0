From: Peter Astrand <peter@cendio.se>
Subject: Re: NFS filename case problem with Netware server
Date: Tue, 3 Feb 2004 21:05:57 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402031621340.27418-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ao85r-0008Ug-A3
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 13:28:27 -0800
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ao85q-0002rY-Ax
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 13:28:26 -0800
To: nfs@lists.sourceforge.net,
	Niall O Broin <niall@magicgoeshere.com>
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


>I have a strange NFS problem and I'm wondering if anyone can shed any
>light. I have some Linux boxes which need to mount some volumes from
>a Netware server via NFS. The appropriate bit of Novell software has
>been installed and configured, and the Linux box can mount the
>volumes.  However, I get errors like this when I do an 'ls' in a
>particular directory:
>
>ls: /mnt/netware/CONTRACT/MDAVIS/A700.TST: No such file or directory

Which Netware version are you using? Netware has several different NFS 
implementations. Each of them has different problems. It also matters if 
you are using NSS or traditional volumes. 

You could try a search on http://support.novell.com/search/kb_index.jsp. 

Another option is to use Ethereal to watch what the server is actually 
sending. 


(Btw, one problem with Netware is that the volumes uses case-insensitive 
file names, but the mount daemon still requires the correct case. Wouldn't 
it make sense for the mount daemon to accept any case? Are there any other 
NFS implementations that works like this? OS X, for example, also has a 
case insensitive fs, I'm told.)


-- 
Peter Åstrand		www.thinlinc.com
Cendio			www.cendio.se
Teknikringen 3		Phone: +46-13-21 46 00
583 30 Linköping





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
