From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: nfs4 filesystem mounted via the "bind" option reports
	wrong fstype
Date: Mon, 27 Aug 2007 20:15:07 +0100
Message-ID: <20070827191507.GI21089@ftp.linux.org.uk>
References: <46D318D3.9020101@oxeva.fr> <20070827184059.GI3118@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org, jkar8572@users.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPk3O-0005yN-VI
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 12:15:15 -0700
In-Reply-To: <20070827184059.GI3118@fieldses.org>
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

On Mon, Aug 27, 2007 at 02:40:59PM -0400, J. Bruce Fields wrote:
 
> There's no reason not to just mount server:/exports/data directly at
> /home/data; the bind mounts are just a workaround for the somewhat
> primitive exports facility on the server side.

Bullshit.  Bindings are first-class operations on _client_, regardless
of fs types involved.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
