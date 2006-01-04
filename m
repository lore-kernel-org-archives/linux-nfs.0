From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils 1.0.8-rc1
Date: Wed, 4 Jan 2006 16:33:18 -0500
Message-ID: <20060104213318.GA31023@fieldses.org>
References: <17314.22172.913247.595571@cse.unsw.edu.au> <1134718387.3699.10.camel@lade.trondhjem.org> <17318.4720.969963.469187@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EuGGM-0003I8-Nb
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 13:33:42 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EuGGL-0004el-4a
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 13:33:42 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17318.4720.969963.469187@cse.unsw.edu.au>
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

On Mon, Dec 19, 2005 at 12:52:48PM +1100, Neil Brown wrote:
> 57 	nor 	P3 	All 	bfields@fieldses.org 	NEW 		unable to export to nfs3 krb5 clients without also export...
> 
>   Messy.... the submitter want to allow mount/STATFS and maybe GETATTR
>   to succeed with only AUTH_UNIX, even though /etc/exports says that
>   krb5 is required to access the filesystem.

You could argue that that's dumb, and I'd be sympathetic.
Unfortunately, it's just the way NFSv2/v3 works--see RFC 2623.  So we
need to support this to interoperate well.

>   As there is no list of authorised hosts available in this context,
>   we really need to give filehandles and stats info away to
>   anyone. i.e. even accept AUTH_NONE.  But we only need to do this for
>   filesystems which require krb5.

We won't have to give this information away to everyone once we adopt
the conventional approach of passing security flavors as export options
(sec=krb5) instead of as clients (gss/krb5(rw,no_subtree_check,...)).

So this is another reason to make that switch.  (The other was that some
people want different security flavor requirements enforced on different
IP network, e.g., in case they have a performance-critical trusted local
network but are also willing to export to the world as long as they come
in with krb5p.)

>   Hmmm.. more thought needed.  I don't think this will get into 1.0.8.

Agreed.

> 58 	nor 	P3 	All 	bfields@fieldses.org 	NEW 		unable to require different security flavors for differen...
>   The bit about having the same format 'exports' file as 'the others',
>   while probably a nice goal, is currently awkward.  So that bit won't
>   be possible for 1.0.8.

Yeah.  I think it's a lower priority too.  What's the history of the
linux exports file format?  Was it invented for linux, or taken from
someplace else?

>   The idea of connection IP addresses with GSS auth connects with bug
>   57 somewhat..

Right.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
