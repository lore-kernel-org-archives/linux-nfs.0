From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS file locking for clustered filesystems
Date: Mon, 2 Aug 2004 12:51:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040802105103.GJ25023@suse.de>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BraTc-0002XI-TJ
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 03:55:32 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BraTc-0005L6-EA
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 03:55:32 -0700
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
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

On Tue, Jul 13, 2004 at 02:32:12PM -0700, Sridhar Samudrala wrote:
> One simple way to avoid blocking new requests is to have lockd get the request
> and schedule the processing of the request to a separate kernel thread. But
> creating a new kernel thread or scheduling from a pool of threads for each
> request may be expensive.

I think making lockd multithreaded and whatnot is going to be very
painful.

If the file system wants to implement its own locking functions, why not
make it the file system's job to deal with blocking on (network) I/O?
You could have it return an error code indicating that the locking
operation would have blocked. Add the NLM request to the list of blocked
locks. When the file system is done, it calls us back via the normal
fl_notify callback, we retry the call, and get the real status code.

The only additional bit of lockd logic that would be needed for this 
is dealing with blocking on unlock requests. Currently lockd only
expects lock requests to block.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
