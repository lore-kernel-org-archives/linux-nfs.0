From: Neil Brown <neilb@suse.de>
Subject: Re: mount.nfs installation
Date: Tue, 28 Aug 2007 10:01:36 +1000
Message-ID: <18131.26080.357802.250064@notabene.brown>
References: <20070827235349.GQ3118@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPoWc-0000cT-5b
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 17:01:42 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPoWe-0006u0-Uc
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 17:01:46 -0700
In-Reply-To: message from J. Bruce Fields on Monday August 27
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

On Monday August 27, bfields@fieldses.org wrote:
> I did a
> 
> 	. autogen.sh
> 	./configure --prefix=/usr/local
> 	make
> 	make install
> 
> from latest git (087c1bf) and it installed mount.nfs{4} in /sbin.  Is
> this operator error on my part or something else?

Given that 'mount' always looks in /sbin for helpers,  there is not a
lot of point in installing elsewhere.

commit 8ab0b89f09dff407101a6f22265873a283e73901

(s/patch/path/ in changelog comment).

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
