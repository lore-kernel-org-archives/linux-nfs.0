From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Error
Date: 23 Oct 2002 19:39:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3cqxgils.fsf@charged.uio.no>
References: <3DB6BF61.4030909@emageon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184PTm-0002da-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 10:39:38 -0700
To: Brian Tinsley <btinsley@emageon.com>
In-Reply-To: <3DB6BF61.4030909@emageon.com>
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

>>>>> " " == Brian Tinsley <btinsley@emageon.com> writes:

     > Does anyone know the possible source/cause of this error
     > message: nfs_statfs: statfs error = 512

ERESTARTSYS? Just means that someone interrupted the task.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
