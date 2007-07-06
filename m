From: Peter Staubach <staubach@redhat.com>
Subject: Re: 'noacl' NFS parameter seems ineffective (Fedora Core 7)
Date: Fri, 06 Jul 2007 07:46:11 -0400
Message-ID: <468E2B83.70908@redhat.com>
References: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>	
	<468D6064.3080307@redhat.com>
	<a90f74cc0707051439t3f471394s1e750ec5c3e4befb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Myles Uyema <mlists@uyema.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6mGP-0000n6-KV
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 04:46:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6mGT-0002Ut-1G
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 04:46:21 -0700
In-Reply-To: <a90f74cc0707051439t3f471394s1e750ec5c3e4befb@mail.gmail.com>
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

Myles Uyema wrote:
> Thanks for the clarification.  I don't suppose there's an option to do 
> what I've described?  Rather - assume that there is no acl, no uid 
> mapping/translation on the server side?

Yes, but there are other ramifications of it.  It is "nfsvers=2" and
you'll be limited to 8K reads and writes...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
