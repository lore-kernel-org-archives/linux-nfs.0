From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_stat_to_errno: bad nfs status return value: 151
Date: 06 Apr 2002 03:00:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs7knld4j8.fsf@charged.uio.no>
References: <3CAE187B.EF7CF412@mainframe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16teZv-0006IZ-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Apr 2002 17:01:15 -0800
To: Terry Bates <tbates@mainframe.ca>
In-Reply-To: <3CAE187B.EF7CF412@mainframe.ca>
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

>>>>> " " == Terry Bates <tbates@mainframe.ca> writes:

     > We're runing RedHat 7.1 and 7.2 on various machines, and they
     > all seem to be getting the same errors.  It was also happening
     > with 6.2.  Here''s a sample from the mesages file:

     > Apr 5 11:55:02 rfl0002 kernel: nfs_stat_to_errno: bad nfs
     > status return value: 151 Apr 5 11:56:19 rfl0002 kernel:
     > nfs_stat_to_errno: bad nfs status return value: 151 Apr 5
     > 11:56:19 rfl0002 kernel: nfs_stat_to_errno: bad nfs status
     > return value: 151

     > This particular machine is running RH7.1 kernel-2.4.2-2

     > Does anyone know what this 151 value means?

It is neither documented in RFC1813 nor in RFC1094. Looks like your
server is sending over its own internal error value instead of a bona
fide NFS error value. This is a server bug.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
