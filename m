From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Re: [autofs] Server/client mismatch over status of a mo
	unt ...
Date: Wed, 19 Feb 2003 08:30:45 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15955.12965.804337.216885@charged.uio.no>
References: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B930D@perm01.woodside.com.au>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'James Pearson' <james-p@moving-picture.com>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lOh8-0002HJ-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 23:31:07 -0800
To: "Kent, Ian I." <Ian.Kent@woodside.com.au>
In-Reply-To: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B930D@perm01.woodside.com.au>
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

>>>>> " " == Ian Kent, <Kent> writes:

     > So, seems that the kernels from 2.4.18 onwards introduced a
     > problem with the NFS code. Symptoms are that 'stat' type
     > operations fail on directories above a certain size. I can 'ls'
     > in my home directory, but not 'ls -l' . If I cd to a smaller
     > directory, then I can 'ls' and 'ls -l'. I can cd to a very big
     > directory and 'ls' still seems to work.

This is not my experience. Could you send me a proper bug-report
(including full client and server details), tcpdump and relevant
info from syslog?

The only changes to the NFS client in 2.4.18 were a fix for a race
condition in which older versions of the file metadata/attributes
could end up replacing newer ones. It only assumes that the 'ctime'
timestamp is working correctly on the server (as described in
RFC1813).

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
