From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: do_IRQ: stack overflow
Date: 17 Oct 2003 08:20:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy8vk3vj7.fsf@charged.uio.no>
References: <765B6B38B4D29D498077F8E644E23B7F023C1207@nlhoe2k02.europe.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AATbE-0002Mr-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 05:20:57 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AATbB-0004I4-6I
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 05:20:53 -0700
To: "Kiernan, Michael" <mkiernan@netapp.com>
In-Reply-To: <765B6B38B4D29D498077F8E644E23B7F023C1207@nlhoe2k02.europe.netapp.com>
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

>>>>> " " == Michael Kiernan <Kiernan> writes:

     > For the record; Steve's patch resolved this.

...but does the latest 2.4.22-bk snapshot?

I'd prefer not avoid having to convert all the nfs_fh and nfs_fattr
structures to use dynamic allocation if at all possible. Removing the
unused readdirplus-specific fields in struct nfs_entry is by far my
first choice for a solution. Now that has been done, then we can start
to worry about the remaining cases.

So has anybody ever seen stack overflow errors in any of the other
functions that allocate nfs_fh/nfs_fattr on the stack? That would be
mainly in nfs_lookup() and nfs_lookup_revalidate().

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
