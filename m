From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs v3: chown not permitted
Date: Mon, 22 Mar 2004 11:23:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322162324.GB27261@fieldses.org>
References: <20040322143922.GA2452@posern.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5SD4-0006uG-2k
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 08:23:30 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B5SD3-0000qL-2Z
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 08:23:29 -0800
To: foo@posern.org
In-Reply-To: <20040322143922.GA2452@posern.org>
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

On Mon, Mar 22, 2004 at 03:39:22PM +0100, foo@posern.org wrote:
> By the way: In which state is nfs v4? - Its already more or less
> usable? <<< because from time to time I am looking at www.nfsv4.org,
> but there is sadly nothing written about the state of development of
> nfsv4...

That website is for everyone involved in nfsv4, not just the linux
implementors.  For linux, you want:

http://www.citi.umich.edu/projects/nfsv4/linux/

Bug reports welcomed, to nfsv4-wg@citi.umich.edu.

Still marked experimental, but should do everything v3 does with a few
exceptions (e.g., reboot recovery, at least on the server side, is still
work in progress).

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
