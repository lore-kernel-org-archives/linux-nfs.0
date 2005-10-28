From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: CAP_DAC_OVERRIDE on nfs
Date: Fri, 28 Oct 2005 14:22:34 -0400
Message-ID: <1130523754.28718.13.camel@lade.trondhjem.org>
References: <20051028180633.GB6852@blackhole.websupport.sk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVYsP-0000GS-HO
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 11:22:53 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EVYsN-000572-Sq
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 11:22:53 -0700
To: stanojr@blackhole.websupport.sk
In-Reply-To: <20051028180633.GB6852@blackhole.websupport.sk>
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

fr den 28.10.2005 klokka 20:06 (+0200) skreiv
stanojr@blackhole.websupport.sk:
> Hello,
> 
> When process with CAP_DAC_OVERRIDE capability on nfs client tried
> to access file or directory on nfs mount where it does not have acces, it got access denied.
> On local fs it work as expected. (CAP_DAC_OVERRIDE bypass filesystem access permission on process
> with uid!=0)
> I am using 2.6.13.4 kernel on client and server and nfs mount is exported with no_root_squash. 
> 
> This is feature or bug ?

It is expected behaviour. Capabilities are not supported by the NFS
protocol.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
