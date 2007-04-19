From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: NFS caching bug is back
Date: Thu, 19 Apr 2007 09:25:48 -0700
Message-ID: <4627980C.2090308@serpentine.com>
References: <46278E27.8050705@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: David Warren <warren@atmos.washington.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeZSA-0004QC-2n
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 09:25:50 -0700
Received: from hierophant.serpentine.com ([64.81.58.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeZSB-0005Bv-A0
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 09:25:52 -0700
In-Reply-To: <46278E27.8050705@atmos.washington.edu>
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

David Warren wrote:
> A bug that we turned in a while ago is back in the 2.6.20 kernels, only 
> worse. I have found it in 2.6.20.6 and 2.6.20.7.

These symptoms look similar to this bug:

http://bugzilla.kernel.org/show_bug.cgi?id=8305

Which has been around since 2.6.17.  Do you find that the problem 
magically resolves itself after a little while?

	<b

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
