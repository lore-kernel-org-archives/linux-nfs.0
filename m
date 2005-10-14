From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS security
Date: Fri, 14 Oct 2005 11:56:54 -0400
Message-ID: <20051014155654.GC26480@fieldses.org>
References: <f872993a0510130004p90cb2eal3dd17d58b892083d@mail.gmail.com> <1129207423.8578.3.camel@lade.trondhjem.org> <f872993a0510140741l1ac0147ep1c6fea89b737434c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQRvg-0002fV-RF
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 08:57:08 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQRvb-00018U-HC
	for nfs@lists.sourceforge.net; Fri, 14 Oct 2005 08:57:06 -0700
To: Raghu R <roverphoenix@gmail.com>
In-Reply-To: <f872993a0510140741l1ac0147ep1c6fea89b737434c@mail.gmail.com>
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

On Fri, Oct 14, 2005 at 07:41:26AM -0700, Raghu R wrote:
> I am sorry I mistyped that I had meant GSS-API and not GAA-API, I actually
> proposed to the professor today he says the scope of the project is huge for
> a single person for a perid of abt 2 months,

Probably so.  And it's already been done, for the most part.

> the professor has suggested something simpler managable like a fix or
> something tp add to security to NFS, can you suggest some?

A couple rpcsec_gss loose ends that need doing:

	* Fix mountd to enable auth_unix mount requests for krb5
	  mounts--needed by people doing rpcsec_gss over NFSv2/v3.
	  See http://bugzilla.linux-nfs.org/show_bug.cgi?id=57
	* Add 3DES, AES, etc. support.
	* Perform experiments to measure the rpcsec_gss performance
	  overhead.

And there are probably plenty of others depending on interest.

Make sure you let the list at nfsv4@linux-nfs.org know what you're
doing.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
