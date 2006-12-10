From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/10] lockd: add new export operation for
	nfsv4/lockd locking
Date: Sun, 10 Dec 2006 13:31:01 -0500
Message-ID: <20061210183101.GA23387@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
	<457A4F52.1020709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GtTS6-0005bK-K7
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 10:31:06 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GtTS5-00075l-Jr
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 10:31:07 -0800
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <457A4F52.1020709@redhat.com>
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

On Sat, Dec 09, 2006 at 12:53:22AM -0500, Wendy Cheng wrote:
> Starting to read these patches .. I see these new APIs are placed in 
> lockd directory. Was there any discussion before to make these generic 
> vfs layer functions ? I'm just curious.

Yeah--see the introductory email.  The new stuff is used only by lockd
and nfsd, and there was an understandable desire not to touch the common
locking code, but I agree that it'd be more elegant to share a common
lock method.  So that's probably what we'll do next time around....

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
