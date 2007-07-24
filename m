From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC:PATCH] How best to handle implicit clearing of
 setuid/setgid bits on NFS?
Date: Tue, 24 Jul 2007 07:42:25 -0400
Message-ID: <20070724074225.730c9845.jlayton@redhat.com>
References: <20070529124705.a1e70735.jlayton@redhat.com>
	<1182982555.5311.67.camel@heimdal.trondhjem.org>
	<20070627221354.02233c58.jlayton@redhat.com>
	<1183037902.6163.29.camel@heimdal.trondhjem.org>
	<20070723150548.8f951bf6.jlayton@redhat.com>
	<1185222803.6582.42.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, aviro@redhat.com,
	nfs@lists.sourceforge.net, nhorman@tuxdriver.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDImj-00070x-OM
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 04:42:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IDImm-0007DH-9l
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 04:42:41 -0700
In-Reply-To: <1185222803.6582.42.camel@localhost>
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

On Mon, 23 Jul 2007 16:33:23 -0400 Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> What is so bloody difficult about remembering to support ATTR_KILL_SUID
> ATTR_KILL_SGID vs all the other ATTR_* flags if you are choosing to
> implement your own .setattr?
> As long as there exists a simple VFS helper to do the translation into
> an ATTR_MODE request, so that those filesystems that rely on the current
> translation by 'notify_change' can easily migrate, then I can't see why
> this is such a problem.
> 

You're quite right. If you declare your own .setattr, then you ought to
know what you're doing. My concern was more about the breadth of the
change and how best to make sure we don't open security holes with this.

On the technical side, I don't think we can just move this into
inode_setattr. The ia_mode really needs to be set before inode_change_ok
is called. So I think we'll have to make sure that all .setattr ops
call the helper explicitly.

I'm working on a patchset now and hope to have something together in a
few days.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
