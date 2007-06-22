From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS debugging helpers
Date: Fri, 22 Jun 2007 14:12:29 -0400
Message-ID: <20070622181229.GB1991@fieldses.org>
References: <467AE021.4000307@oracle.com> <20070621203748.GF4094@fieldses.org>
	<467BFB5D.3040003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1ncT-0000BD-Sw
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 11:12:30 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1ncW-0007j7-Vj
	for nfs@lists.sourceforge.net; Fri, 22 Jun 2007 11:12:33 -0700
In-Reply-To: <467BFB5D.3040003@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Jun 22, 2007 at 12:39:57PM -0400, Chuck Lever wrote:
> J. Bruce Fields wrote:
> >On Thu, Jun 21, 2007 at 04:31:29PM -0400, Chuck Lever wrote:
> >>I thought I remembered that nfs-utils has simple programs to set NFS/RPC 
> >>debugging flags, but I couldn't find them.
> >>
> >>So I constructed a couple of Python scripts to remember the flag names 
> >>and values (see attached).  They are still a little raw.
> >>
> >>Is there anything like this already out there?
> >
> >Try
> >
> >	man rpcdebug
> >
> >It comes from nfs-utils/tools/rpcdebug/.
> 
> Ja, that's what I remembered.
> 
> Not necessarily to Bruce:  Is it actively maintained?  If a new 
> debugging flag is added, is this tool updated by someone?

Sounds like a volunteer!

git hsows the last update (to update some flags, add the manpage, and
install everything) as being by Greg Banks last in July 2006.

I have to admit, just now I needed to turn on some dprintk's, and did it
by looking up the #define by hand.  I forgot about rpcdebug even after
having talked about it just yesterday....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
