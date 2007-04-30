From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: flock and lockf over NFS and the 'pid' in lockd requests.
Date: Mon, 30 Apr 2007 00:16:40 -0400
Message-ID: <46356DA8.4000902@redhat.com>
References: <17973.19011.690165.95878@notabene.brown>	<1177899233.6400.58.camel@heimdal.trondhjem.org>
	<17973.26166.844328.279844@notabene.brown>
	<46356C57.1040601@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiN9R-0007If-9M
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 21:06:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiN9T-0003zs-LS
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 21:06:16 -0700
In-Reply-To: <46356C57.1040601@redhat.com>
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

Wendy Cheng wrote:

> Neil Brown wrote:
>
>>
>> What would you think of an "noflock" option to allow people to choose
>> the old practice of not supporting flock???
>>
Sorry, shouldn't make a joke as previous post - I should have said this 
is a sensible solution for now.

-- Wendy

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
