From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: "nfs warning: mount version older than kernel" reported for 2.6.4 kernel on Fedora Core 1.0
Date: Fri, 19 Mar 2004 15:32:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040319203231.GA25569@fieldses.org>
References: <41089CB27BD8D24E8385C8003EDAF7AB084833@karl.alexa.com> <20040319184931.GF29237@perlsupport.com> <1079725155.2530.30.camel@lade.trondhjem.org> <20040319200314.GG29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Guolin Cheng <guolin@alexa.com>,
	"NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4Qfd-0001Ry-Aw
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 12:32:45 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B4Qfc-0005Iv-4k
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 12:32:44 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040319200314.GG29237@perlsupport.com>
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

On Fri, Mar 19, 2004 at 03:03:14PM -0500, Chip Salzenberg wrote:
> According to Trond Myklebust:
> > (BTW: we're *still* waiting to hear from this list about including
> > the RPCSEC_GSS + NFSv4 support daemons into the official nfs-utils)
> 
> Well, I'd be glad to look at patches for inclusion in Debian's
> nfs-utils.  I'd probably put them in CVS but on a branch.

The first four patches here:

  http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.0.6-8/

are the ones we'd like to get into nfs-utils.  (Actually, Neil applied
the first already, so it's just 2, 3, and 4.)

The original complaint of course is about mount, for which util-linux
needs patches:

  http://www.citi.umich.edu/projects/nfsv4/linux/util-linux-patches/2.11z-3/

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
