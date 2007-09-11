From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/19] RFC: fg/bg and fallback support for mount.nfs
Date: Mon, 10 Sep 2007 20:58:22 -0400
Message-ID: <20070911004840.24927.47585.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu5C-0002vg-Cx
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:26 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu5G-0007kl-2u
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:31 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0wD6I027257
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:58:13 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0wMiK024984
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:58:23 -0400
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

I'm posting this for review and comments.  This patch series is incomplete
and known not to work.  I'm still working out the bugs.

In this series, I implement support for probing the server and retrying
when an initial text-based mount attempt fails, and support for retrying
text-based mount requests in the foreground and background.

Road map:

Clean-up:
01 use-child-argument-for-nfsmount-s

Implement lexical parsing helpers to handle mount option manipulation:
02 add-mount-option-parsing-helpers
03 use-new-option-parsing-facility

Use the new parsing facility to fix a problem with the mounthost option:
04 fix-mounthost-option

Clean-up:
05 remove-unused-string-parsing-helpers

Adjust error reporting for text-based mounts:
06 rename-mount-errors
07 add-new-mount-errors-function
08 handle-new-error-reports

Clean-up:
09 comment-network-functions

Add structure for falling back:
10 add-try-nfsmount-and-friend
11 use-try-nfsmount-and-friend
12 add-rewrite-mount-options
13 add-fallback-support

Add structure for foreground NFS mounts:
14 add-nfs-foreground-mount
15 use-nfs-foreground-mount

Add structure for background NFS mounts:
16 add-bg-helpers
17 add-bg-for-nfs-mounts

Duplicate NFS implementation for NFSv4 mounts:
18 fg-bg-helpers-for-nfs4
19 add-fg-and-bg-for-nfs4-mounts

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
