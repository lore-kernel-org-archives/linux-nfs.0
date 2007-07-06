From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 3/3] NLM: fix source address of callback to client
Date: Fri, 6 Jul 2007 17:27:14 +0200
Message-ID: <20070706152714.GB18242@janus>
References: <20070705152650.GD6603@janus> <20070706134404.GC10812@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6piE-0001s7-ID
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 08:27:33 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6piG-0003xb-R7
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 08:27:18 -0700
In-Reply-To: <20070706134404.GC10812@fieldses.org>
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

On Fri, Jul 06, 2007 at 09:44:04AM -0400, J. Bruce Fields wrote:
> On Thu, Jul 05, 2007 at 05:26:50PM +0200, Frank van Maarseveen wrote:
> > Use the destination address of the original NLM request as the
> > source address in callbacks to the client.
> 
> What are the impliciations of changing nlm_lookup_host to also match on
> server ip address?  (Doesn't that go beyond the minimum changes
> necessary just to get the source ip address right on grant callbacks?)

The address must be kept somewhere for creating a callback RPC request
later: the old request is gone by then. Multiple struct nlm_host per
client have always been possible because protocol and version must match
too so I can't find any problem with this.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
