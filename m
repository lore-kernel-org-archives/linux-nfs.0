From: Christoph Hellwig <hch@infradead.org>
Subject: Re: NFS servers stop answering
Date: Wed, 5 Jan 2005 23:07:53 +0000
Message-ID: <20050105230753.GA9474@infradead.org>
References: <FZKMSX4Gxd3gWicigQk00050a35@FZKMSX4.ka.fzk.de> <41DC725C.7050203@iwr.fzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmKG2-0006h3-6K
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 15:08:02 -0800
Received: from [213.146.154.40] (helo=pentafluge.infradead.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CmKFy-0008Id-Mq
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 15:08:02 -0800
To: Jos van Wezel <jvw@iwr.fzk.de>
In-Reply-To: <41DC725C.7050203@iwr.fzk.de>
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

On Thu, Jan 06, 2005 at 12:03:56AM +0100, Jos van Wezel wrote:
> We run a couple of NFS servers (RedHat 3.0, 2.4.21-15.0.3, nfs-utils 
> 1.0.6) that have access to the same underlying file system (GPFS). 
> Sometimes the servers stop responding to mount requests. Clients give up 
> with 'RPC: Timed out messages'. A second later all is green again and 
> mount requests go through without a hitch.

Can your reproduce the issues without propritary (GFPS) or know
totally buggy (it's clue code) modules loaded?



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
