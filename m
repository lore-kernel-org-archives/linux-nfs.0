From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS dentry caching mechanism
Date: Fri, 27 Jan 2006 09:26:04 -0500
Message-ID: <1138371965.8712.30.camel@lade.trondhjem.org>
References: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>
	 <1138317247.8770.39.camel@lade.trondhjem.org> <43DA2240.2090900@redhat.com>
	 <1138369456.8712.14.camel@lade.trondhjem.org> <43DA24D3.3090400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: uketinen@us.ibm.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2UYZ-0006Ic-NO
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 06:26:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F2UYZ-0008Eu-4H
	for nfs@lists.sourceforge.net; Fri, 27 Jan 2006 06:26:31 -0800
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <43DA24D3.3090400@redhat.com>
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

On Fri, 2006-01-27 at 08:49 -0500, Peter Staubach wrote:
> Well, the need for the stronger consistency in this case reduces the
> performance benefits, but does not eliminate them.  A GETATTR will
> always be cheaper than a LOOKUP, especially one that will mostly
> likely return ENOENT.

This is still unacceptable: it leads to whole truckloads of unnecessary
forced GETATTR calls on something like an nfsroot system, where $PATH
and $LD_LIBRARY_PATH need to be explored every single time the user
types in a command.
You appeared to imply that the read-only filesystem case was treated
differently on Solaris, but that sucks too: a read-only flag just means
that _you_ can't modify the filesystem, not that others can't.

Furthermore, in cases such as the one that Usha describes, we don't
actually _care_ about revalidating a negative dentry and/or looking up a
new dentry. Do it using intents, and you can probably skip all the crap
in nfs_lookup_revalidate+nfs_lookup: after all you need in order to send
a valid RMDIR command is the filehandle of the parent, and a name.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
