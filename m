From: Olaf Kirch <okir@suse.de>
Subject: Re: [pme@devphil.com: Bug#239158: Strange exportfs problems, fantastically unhelpful error message]
Date: Mon, 22 Mar 2004 10:46:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322094624.GB11393@suse.de>
References: <20040321153515.GW29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5M0t-0007kM-Jz
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 01:46:31 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5M0p-0008J5-Rn
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 01:46:28 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040321153515.GW29237@perlsupport.com>
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

On Sun, Mar 21, 2004 at 10:35:15AM -0500, Chip Salzenberg wrote:
> This Debian bug report includes an exportfs problem which I suspect is
> due to one export tree under the other, and an error message complaint
> which I think is justified....

Well, what he tries to do is invalid from the kernel point of view.
And unfortunately there's no "EBADNFSEXPORTPLEASEREADTHEMANPAGE" :-)

I agree though this issue is confusing to many people. Wasn't there
some work going on to allow an arbitrary configuration of exports?
For each file handle, we need to establish the dentry chain anyway,
so it should not be too hard to find the proper export entry.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
