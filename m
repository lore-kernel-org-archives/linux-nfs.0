From: "Mark Maggelet" <mark@educationplanet.com>
Subject: cp: failed to preserve ownership for `/backup2/restart':
	Operation not permitted
Date: Tue, 25 Sep 2007 14:39:27 -0700
Message-ID: <2127a07b0709251439s674dc1act8c37f64c789e4657@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaI7n-00021p-NT
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 14:39:23 -0700
Received: from rv-out-0910.google.com ([209.85.198.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IaI7r-0005ch-M8
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 14:39:28 -0700
Received: by rv-out-0910.google.com with SMTP id g11so7169680rvb
	for <nfs@lists.sourceforge.net>; Tue, 25 Sep 2007 14:39:27 -0700 (PDT)
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

Hi,
Sorry if this has been covered.
I'm trying to mount a nfs share from my nas to my linux server(rhel4).
I get this error and the file permissions of the copied file appear as
nfsnobody.nfsnobody

Is there a way to keep permissions?

Thanks,
- Mark

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
