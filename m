From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Does mountd/statd really need to listen on a privileged
 port??
Date: Mon, 16 Apr 2007 14:13:45 -0400
Message-ID: <4623BCD9.3090501@RedHat.com>
References: <17950.44333.118970.276558@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdVho-00063x-Ti
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 11:13:36 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdVhq-0007L1-6S
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 11:13:39 -0700
In-Reply-To: <17950.44333.118970.276558@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Sorry for the delayed response...

Neil Brown wrote:

> 
> But is there some reason that mountd/statd need a priv port that I
> haven't thought of?
I don't think so... since neither mountd or statd checks to see
if the source port is a priv port, its not clear why they should
listen on one...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
