From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] XDR strings use an unsigned length
Date: Thu, 01 Nov 2007 16:56:41 -0400
Message-ID: <20071101205057.5503.90636.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no, neilb@suse.de, bfields@fieldses.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Inh6L-0007hf-Cd
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:17 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Inh6Q-0005Uo-0U
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 13:57:23 -0700
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

Hi Trond, Neil, Bruce...

The following patch series replaces

   [PATCH 06/27] SUNRPC: Fix xdr_decode_string_inplace() argument signage

which I posted last week.

XDR variable length strings use an unsigned length.  This patch series
offers a series of clean ups to make the treatment of file names and path
names in the NFS and NLM server consistent with the XDR specification and
other areas of the NFS client.

-- 
corporate:    <chuck dot lever at oracle dot com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
